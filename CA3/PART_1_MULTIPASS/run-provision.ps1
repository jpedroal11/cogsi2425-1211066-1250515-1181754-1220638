# =====================================
# CA3 Part 1 Multipass - Run Provisioning Script
# Windows PowerShell Version
# =====================================

$VM_NAME = "ca3-part1-multipass"

# Repository configuration
$REPO_URL = "git@github.com:jpedroal11/cogsi2425-1211066-1250515-1181754-1220638.git"
$BRANCH_NAME = "feature/vagrant-prt1"
$PROJ_DIR = "/home/ubuntu/workspace"

# Automation flags
$CLONE_REPO = if ($env:CLONE_REPO) { $env:CLONE_REPO } else { "true" }
$BUILD_APP = if ($env:BUILD_APP) { $env:BUILD_APP } else { "true" }
$START_APP = if ($env:START_APP) { $env:START_APP } else { "false" }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CA3 Part 1 - Running Provisioning" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Repository: $REPO_URL"
Write-Host "Branch: $BRANCH_NAME"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CLONE_REPO: $CLONE_REPO"
Write-Host "BUILD_APP:  $BUILD_APP"
Write-Host "START_APP:  $START_APP"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if VM exists
$existingVM = multipass list 2>&1 | Select-String -Pattern "^$VM_NAME"
if (-not $existingVM) {
    Write-Host "ERROR: VM '$VM_NAME' not found!" -ForegroundColor Red
    Write-Host "Run .\setup.ps1 first to create the VM" -ForegroundColor Yellow
    exit 1
}

# Check VM status
$vmState = (multipass info $VM_NAME | Select-String -Pattern "State:\s+(\w+)").Matches.Groups[1].Value

if ($vmState -ne "Running") {
    Write-Host "Starting VM..." -ForegroundColor Yellow
    multipass start $VM_NAME
    Start-Sleep -Seconds 5
}

Write-Host "Setting environment variables in VM..." -ForegroundColor Cyan
multipass exec $VM_NAME -- bash -c "echo 'export REPO_URL=$REPO_URL' >> /home/ubuntu/.profile"
multipass exec $VM_NAME -- bash -c "echo 'export BRANCH_NAME=$BRANCH_NAME' >> /home/ubuntu/.profile"
multipass exec $VM_NAME -- bash -c "echo 'export PROJ_DIR=$PROJ_DIR' >> /home/ubuntu/.profile"
multipass exec $VM_NAME -- bash -c "echo 'export CLONE_REPO=$CLONE_REPO' >> /home/ubuntu/.profile"
multipass exec $VM_NAME -- bash -c "echo 'export BUILD_APP=$BUILD_APP' >> /home/ubuntu/.profile"
multipass exec $VM_NAME -- bash -c "echo 'export START_APP=$START_APP' >> /home/ubuntu/.profile"

Write-Host ""
Write-Host "Running provisioning script in VM..." -ForegroundColor Cyan
Write-Host "This may take 5-10 minutes..." -ForegroundColor Cyan
Write-Host ""

# Run provisioning
multipass exec $VM_NAME -- bash -c "source /home/ubuntu/.profile && /home/ubuntu/provision.sh"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Provisioning Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Get VM IP
$VM_IP = (multipass exec $VM_NAME -- hostname -I).Split()[0]

Write-Host ""
Write-Host "Access your application:" -ForegroundColor White
Write-Host "  Spring Boot: http://$VM_IP`:8080" -ForegroundColor Cyan
Write-Host "  H2 Console:  http://$VM_IP`:8080/h2" -ForegroundColor Cyan
Write-Host ""
Write-Host "H2 Console Connection Settings:" -ForegroundColor White
Write-Host "  JDBC URL: jdbc:h2:file:/home/ubuntu/h2-data/h2db" -ForegroundColor Gray
Write-Host "  Username: sa" -ForegroundColor Gray
Write-Host "  Password: password" -ForegroundColor Gray
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor White
Write-Host "  View logs:   multipass exec $VM_NAME -- tail -f /home/ubuntu/spring-app.log" -ForegroundColor Gray
Write-Host "  Start app:   multipass exec $VM_NAME -- /home/ubuntu/scripts/start-spring.sh" -ForegroundColor Gray
Write-Host "  Shell:       multipass shell $VM_NAME" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Green