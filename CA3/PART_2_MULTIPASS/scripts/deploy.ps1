# deploy.ps1 - Automated Multipass Deployment Script
# CA3 Part 2 - Automatic Setup

param(
    [string]$RepoUrl = "https://github.com/jpedroal11/cogsi2425-1211066-1250515-1181754-1220638.git",
    [switch]$SkipKeys,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
CA3 Part 2 - Multipass Automated Deployment

Usage: .\scripts\deploy.ps1 [options]

Options:
  -RepoUrl <url>    Git repository URL (default: cogsi2425 repo)
  -SkipKeys         Skip SSH key generation if already exists
  -Help             Show this help message

Examples:
  .\scripts\deploy.ps1
  .\scripts\deploy.ps1 -RepoUrl https://github.com/user/repo.git
  .\scripts\deploy.ps1 -SkipKeys

"@
    exit 0
}

function Write-Step {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "SUCCESS: $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "INFO: $Message" -ForegroundColor Yellow
}

# Start
Write-Host "`nCA3 Part 2 - Multipass Automated Deployment" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Step 1: Generate SSH Keys
Write-Step "Step 1: Generating SSH Keys"

if (-not $SkipKeys -and -not (Test-Path "ssh-keys\multipass_key")) {
    New-Item -ItemType Directory -Force -Path ssh-keys | Out-Null
    Write-Info "Generating RSA 4096 key pair..."
    ssh-keygen -t rsa -b 4096 -f ssh-keys\multipass_key -C "multipass-ca3-part2" -N '""' -q
    Write-Success "SSH keys generated at ssh-keys\multipass_key"
} elseif (Test-Path "ssh-keys\multipass_key") {
    Write-Info "SSH keys already exist, skipping generation"
} else {
    Write-Error "SSH key generation failed"
    exit 1
}

# Step 2: Create Database VM
Write-Step "Step 2: Creating Database VM (db)"

$PUBLIC_KEY = Get-Content .\ssh-keys\multipass_key.pub -Raw

$cloudInitDb = @"
#cloud-config
users:
  - name: ubuntu
    ssh_authorized_keys:
      - $($PUBLIC_KEY.Trim())
    sudo: ALL=(ALL) NOPASSWD:ALL
package_update: true
package_upgrade: true
packages:
  - openjdk-17-jdk
  - ufw
  - netcat-openbsd
"@

Write-Info "Launching db VM (2 CPUs, 2GB RAM, 10GB Disk)..."
$cloudInitDb | multipass launch --name db --cpus 2 --mem 2G --disk 10G --cloud-init - 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Success "VM db created"
} else {
    Write-Error "Failed to create VM db"
    exit 1
}

# Get db IP
$dbInfo = multipass info db --format json | ConvertFrom-Json
$DB_IP = $dbInfo.info.db.ipv4[0]
Write-Success "VM db IP: $DB_IP"

# Step 3: Configure H2 on db VM
Write-Step "Step 3: Configuring H2 Database Server"

Write-Info "Transferring setup script to db VM..."
multipass transfer scripts\setup-db.sh db:/home/ubuntu/

Write-Info "Running setup script on db VM..."
multipass exec db -- bash /home/ubuntu/setup-db.sh

Write-Success "H2 Database Server configured and running"

# Step 4: Create Application VM
Write-Step "Step 4: Creating Application VM (app)"

$cloudInitApp = @"
#cloud-config
users:
  - name: ubuntu
    ssh_authorized_keys:
      - $($PUBLIC_KEY.Trim())
    sudo: ALL=(ALL) NOPASSWD:ALL
package_update: true
package_upgrade: true
packages:
  - openjdk-17-jdk
  - curl
  - netcat-openbsd
  - git
"@

Write-Info "Launching app VM (2 CPUs, 2GB RAM, 10GB Disk)..."
$cloudInitApp | multipass launch --name app --cpus 2 --mem 2G --disk 10G --cloud-init - 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Success "VM app created"
} else {
    Write-Error "Failed to create VM app"
    exit 1
}

# Get app IP
$appInfo = multipass info app --format json | ConvertFrom-Json
$APP_IP = $appInfo.info.app.ipv4[0]
Write-Success "VM app IP: $APP_IP"

# Step 5: Configure Firewall
Write-Step "Step 5: Configuring Firewall (UFW)"

Write-Info "Configuring UFW to allow only app VM access to db..."
multipass exec db -- bash -c "sudo ufw --force enable && sudo ufw allow 22/tcp && sudo ufw allow from $APP_IP to any port 9092 proto tcp"

Write-Success "Firewall configured"

# Step 6: Configure Application
Write-Step "Step 6: Configuring Spring Boot Application"

Write-Info "Transferring setup script to app VM..."
multipass transfer scripts\setup-app.sh app:/home/ubuntu/

Write-Info "Running setup script on app VM..."
multipass exec app -- bash /home/ubuntu/setup-app.sh $DB_IP "$RepoUrl"

Write-Success "Application configured"

# Step 7: Start Application
Write-Step "Step 7: Starting Application"

Write-Info "Running startup check..."
multipass exec app -- bash -c "cd ~ && ./wait-for-db.sh $DB_IP 9092"

Write-Info "Starting Spring Boot application..."
$projectPath = if ($RepoUrl) { "~/repo/CA2/PART_2/ca2-part2" } else { "~/ca2-part2" }
multipass exec app -- bash -c "cd $projectPath && nohup ./gradlew bootRun --no-daemon > ~/app.log 2>&1 &"

Write-Success "Application starting in background"
Write-Info "Waiting 15 seconds for application to initialize..."
Start-Sleep -Seconds 15

# Step 8: Verify
Write-Step "Step 8: Verification"

Write-Info "Testing API endpoint..."
try {
    $response = multipass exec app -- curl -s http://localhost:8080/employees
    Write-Host $response
    Write-Success "API is responding"
} catch {
    Write-Error "API test failed"
}

# Summary
Write-Host "`n=== Deployment Complete ===" -ForegroundColor Green
Write-Host "`nVM Information:"
Write-Host "  DB VM IP:   $DB_IP"
Write-Host "  App VM IP:  $APP_IP"
Write-Host "`nAccess URLs:"
Write-Host "  Employees:  http://${APP_IP}:8080/employees"
Write-Host "  Orders:     http://${APP_IP}:8080/orders"
Write-Host "`nUseful Commands:"
Write-Host "  multipass list"
Write-Host "  multipass shell db"
Write-Host "  multipass shell app"
Write-Host "  multipass exec app -- tail -f /home/ubuntu/app.log`n"
