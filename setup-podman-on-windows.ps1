Write-Host "Dont press any key during Podman setup.. `n" -ForegroundColor Green -BackgroundColor Black
Write-Host "Pre-req setup in progress.... `n" -ForegroundColor Green -BackgroundColor Black

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart


# Install Chocolatey 
Write-Host "Installing Chocolatey.... `n" -ForegroundColor Green -BackgroundColor Black
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
Write-Host "Chocolatey installed.... `n" -ForegroundColor Green -BackgroundColor Black



# Install Python 
Write-Host "Installing Python.... `n" -ForegroundColor Green -BackgroundColor Black 
choco install python3 --force
Write-Host "Python installed..... `n" -ForegroundColor Green -BackgroundColor Black

# Calling podman-setup script
# Download directory (modify if needed)
$downloadDir = "C:\temp"
$installDir = "C:\Program Files\RedHat"
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$composeDir = "$DesktopPath\compose"

# Check installation status of Podman
if (Test-Path "$installDir\podman.exe") 
{
Write-Host "Podman already installed..... `n" -ForegroundColor Green -BackgroundColor Black
} 
else 
{
Write-Host "Installing Podman,Podman-Compose,Podman Desktop.... `n" -ForegroundColor Green -BackgroundColor Black



# Download URL for the latest Podman installer (adjust as needed)
$podmandownloadUrl = "https://github.com/containers/podman/releases/download/v5.0.2/podman-5.0.2-setup.exe"
$composedownloadUrl = "https://github.com/containers/podman-compose/archive/devel.tar.gz"


# Create Compose directory if it doesn't exist
if (-not (Test-Path $composeDir)) {
  New-Item -ItemType Directory -Path $composeDir
}

# Create Download directory if it doesn't exist
if (-not (Test-Path $downloadDir)) {
  New-Item -ItemType Directory -Path $downloadDir
}

# Create Podman install directory if it doesn't exist
if (-not (Test-Path $installDir)) {
  New-Item -ItemType Directory -Path $installDir
}


# Download the installer
Write-Host "Downloading Podman installer..." -ForegroundColor Green -BackgroundColor Black
Invoke-WebRequest -Uri $podmandownloadUrl -OutFile "$downloadDir\podman-5.0.2-setup.exe"


# Check download status

if (Test-Path "$downloadDir\podman-5.0.2-setup.exe") {
  Write-Host "Download complete..... `n" -ForegroundColor Green -BackgroundColor Black
} else {
  Write-Host "Failed to download Podman installer.... `n" -ForegroundColor Green -BackgroundColor Black
  Exit 1
}

# Install Podman 
Write-Host "Installing Podman.... `n" -ForegroundColor Green -BackgroundColor Black
Start-Process -Wait -FilePath "$downloadDir\podman-5.0.2-setup.exe" -ArgumentList '/S','/v','/qn' -passthru
Write-Host "Podman installed..... `n" -ForegroundColor Green -BackgroundColor Black


#Install Podman compose
Write-Host "Installing Podman Compose.... `n" -ForegroundColor Green -BackgroundColor Black
pip3 install podman-compose
#pip3 install https://github.com/containers/podman-compose/archive/devel.tar.gz
Write-Host "Podman Compose installed.... `n" -ForegroundColor Green -BackgroundColor Black


# Configure Podman

cmd /c @"
echo y|"$installDir\Podman\podman.exe" machine reset && "$installDir\Podman\podman.exe" machine init && "$installDir\Podman\podman.exe" machine set --rootful && "$installDir\Podman\podman.exe" machine start && echo Displaying date using Podman && echo: && "$installDir\Podman\podman.exe" run ubi8-micro date
"@

#Install Podman Desktop
Write-Host "Installing Podman-Desktop.... `n" -ForegroundColor Green -BackgroundColor Black
choco install podman-desktop -y --force
Write-Host "Podman Desktop installation completed.... `n" -ForegroundColor Green -BackgroundColor Black
}
