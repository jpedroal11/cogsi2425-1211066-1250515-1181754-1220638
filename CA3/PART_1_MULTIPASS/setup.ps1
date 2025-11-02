# =====================================
# CA3 Part 1 - Multipass Setup Script
# Windows PowerShell Version
# =====================================

$VM_NAME = "ca3-part1-multipass"
$VM_CPUS = 2
$VM_MEMORY = "4G"
$VM_DISK = "15G"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CA3 Part 1 - Multipass Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VM Name: $VM_NAME"
Write-Host "CPUs: $VM_CPUS"
Write-Host "Memory: $VM_MEMORY"
Write-Host "Disk: $VM_DISK"
Write-Host "========================================" -ForegroundColor Cyan

# Check if multipass is installed
try {
    $version = multipass version 2>&1
    Write-Host "Multipass is installed" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Multipass is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Multipass:" -ForegroundColor Yellow
    Write-Host "  Download from: https://multipass.run/download/windows" -ForegroundColor Yellow
    exit 1
}

# Check if VM already exists
$existingVM = multipass list 2>&1 | Select-String -Pattern "^$VM_NAME"
if ($existingVM) {
    Write-Host ""
    Write-Host "VM '$VM_NAME' already exists!" -ForegroundColor Yellow
    $response = Read-Host "Delete and recreate? (y/n)"
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Host "Deleting existing VM..." -ForegroundColor Yellow
        multipass delete $VM_NAME
        multipass purge
        Write-Host "VM deleted" -ForegroundColor Green
    } else {
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
}

# Check if cloud-init.yaml exists
if (-not (Test-Path "cloud-init.yaml")) {
    Write-Host "ERROR: cloud-init.yaml not found!" -ForegroundColor Red
    Write-Host "Make sure you're running this script from the PART_1_MULTIPASS directory" -ForegroundColor Yellow
    exit 1
}

# Check if scripts folder exists
if (-not (Test-Path "scripts")) {
    Write-Host "ERROR: scripts/ folder not found!" -ForegroundColor Red
    Write-Host "Make sure the scripts folder exists in the current directory" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Creating VM with cloud-init configuration..." -ForegroundColor Cyan
Write-Host "This may take 2-5 minutes..." -ForegroundColor Cyan
Write-Host ""

# Launch VM with cloud-init
multipass launch 22.04 --name $VM_NAME --cpus $VM_CPUS --memory $VM_MEMORY --disk $VM_DISK --cloud-init cloud-init.yaml

Write-Host ""
Write-Host "VM created successfully!" -ForegroundColor Green
Write-Host ""

# Wait for VM to be fully ready
Write-Host "Waiting for VM to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Upload scripts folder
Write-Host ""
Write-Host "Uploading scripts to VM..." -ForegroundColor Cyan
Get-ChildItem -Path "scripts\*" | ForEach-Object {
    multipass transfer $_.FullName "${VM_NAME}:/home/ubuntu/scripts/"
}

# Upload provision.sh
Write-Host "Uploading provision script..." -ForegroundColor Cyan
multipass transfer provision.sh "${VM_NAME}:/home/ubuntu/"

# Make scripts executable
Write-Host "Making scripts executable..." -ForegroundColor Cyan
multipass exec $VM_NAME -- chmod +x /home/ubuntu/scripts/*.sh
multipass exec $VM_NAME -- chmod +x /home/ubuntu/provision.sh

Write-Host "Scripts uploaded!" -ForegroundColor Green

# Get VM IP
$vmInfo = multipass info $VM_NAME
$VM_IP = ($vmInfo | Select-String -Pattern "IPv4:\s+(\d+\.\d+\.\d+\.\d+)").Matches.Groups[1].Value

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "VM Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "VM Name: $VM_NAME"
Write-Host "VM IP:   $VM_IP"
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: SSH Key Setup Required" -ForegroundColor Yellow
Write-Host ""
Write-Host "Before running the provisioning script, you need to:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Generate SSH key in the VM:" -ForegroundColor White
Write-Host "   multipass exec $VM_NAME -- ssh-keygen -t rsa -b 2048 -f /home/ubuntu/.ssh/id_rsa -q -N ''" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Get the public key:" -ForegroundColor White
Write-Host "   multipass exec $VM_NAME -- cat /home/ubuntu/.ssh/id_rsa.pub" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Add it to GitHub:" -ForegroundColor White
Write-Host "   Go to: https://github.com/settings/keys" -ForegroundColor Cyan
Write-Host "   Click 'New SSH key' and paste the public key" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. After adding the key to GitHub, run provisioning:" -ForegroundColor White
Write-Host "   .\run-provision.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Green