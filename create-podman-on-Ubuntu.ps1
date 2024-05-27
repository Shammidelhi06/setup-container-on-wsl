# Check if WSL is installed
if (-not (Get-Command -Name "wsl.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "WSL is not installed on this system." -ForegroundColor Red
    Write-Host "Enabling WSL and Virtual Machine Platform..." -ForegroundColor Yellow
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    Restart-Service LxssManager
    return
}
else {
    Write-Host "WSL is already installed on this system." -ForegroundColor Green
}

# Install Chocolatey
Write-Host "Installing Chocolatey.." -ForegroundColor Yellow
choco install chocolatey -y
choco upgrade chocolatey -y
Write-Host "Chocolatey installed.... `n" -ForegroundColor Green -BackgroundColor Black


# Install Python 
Write-Host "Installing Python.... `n" -ForegroundColor Green -BackgroundColor Black 
choco install python3 --force
Write-Host "Python installed..... `n" -ForegroundColor Green -BackgroundColor Black


# Download and install WSL update
$msiUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"

# Specify the local path to save the MSI file
$msiPath = "$($env:TEMP)\package.msi"

# Download the MSI file
Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath

# Install the MSI file silently
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /quiet" -Wait

# Set WSL default version to 2
Write-Host "Setting WSL default version to 2..." -ForegroundColor Yellow
wsl --set-default-version 2

# Install the Ubuntu Distribution
wsl --install -d Ubuntu
wsl -- /bin/bash -c "echo Ubuntu is getting installed"

# Wait for installation to complete
Write-Host "Waiting for the installation to complete..." -ForegroundColor Yellow
Start-Sleep -Seconds 30


# Update packages
Write-Host "Installing Podman and other packages" -ForegroundColor Yellow
wsl -d Ubuntu -e /bin/bash -c "sudo apt-get update -y 2>/dev/null && sudo apt-get upgrade -y 2>/dev/null"
wsl -d Ubuntu -e /bin/bash -c "apt-get install python3 -y 2>/dev/null && apt-get install python3-pip -y 2>/dev/null"
wsl -d Ubuntu -e /bin/bash -c "apt-get install podman -y 2>/dev/null"
wsl -d Ubuntu -e /bin/bash -c "pip3 install podman-compose 2>/dev/null"


# Wait for installation to complete
Write-Host "Package is being installed..." -ForegroundColor Yellow
Start-Sleep -Seconds 30


# Enable systemd in WSL2
Write-Host "Enabling systemd in WSL2..." -ForegroundColor Yellow
$wslConfigPath = "$env:USERPROFILE\.wslconfig"
$wslConfigContent = @"
[wsl2]
# Enable systemd
systemd=true
"@
$wslConfigContent | Out-File -Encoding ASCII $wslConfigPath


# Set Ubuntu as default Distribution
wsl --set-default Ubuntu
Start-Sleep -Seconds 30


# Ensure the Ubuntu distribution has started
wsl -d Ubuntu -e bash -c "echo 'Ubuntu distributation is running'"

# Ensure the Podman has started
wsl -d Ubuntu -e bash -c "podman ps 2>/dev/null"
