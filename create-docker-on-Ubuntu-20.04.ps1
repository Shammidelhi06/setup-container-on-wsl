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

# Install the Ubuntu-20.04 Distribution
wsl --install -d Ubuntu-20.04
wsl -- /bin/bash -c "echo Ubuntu-20.04 is getting installed"

# Wait for installation to complete
Write-Host "Waiting for the installation to complete..." -ForegroundColor Yellow
Start-Sleep -Seconds 30


# Update packages
Write-Host "Installing Docker and other packages" -ForegroundColor Yellow
wsl -d Ubuntu-20.04 -e /bin/bash -c "sudo apt-get update -y 2> /dev/null && sudo apt-get upgrade -y 2> /dev/null"
wsl -d Ubuntu-20.04 -e /bin/bash -c "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh 2> /dev/null && sudo usermod -aG docker root"
wsl -d Ubuntu-20.04 -e /bin/bash -c "apt-get install docker-compose -y 2> /dev/null"
wsl -d Ubuntu-20.04 -e /bin/bash -c "/usr/sbin/service docker start > /dev/null 2>&1"


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


# Set Ubuntu-20.04 as default Distribution
wsl --set-default Ubuntu-20.04
Start-Sleep -Seconds 30


# Ensure the Ubuntu-20.04 distribution is started
wsl -d Ubuntu-20.04 -e bash -c "echo 'Ubuntu-20.04 is running'"


# Ensure the Ubuntu-20.04 distribution is started
wsl -d Ubuntu-20.04 -e bash -c "docker --version"
wsl -d Ubuntu-20.04 -e bash -c "docker compose version"
