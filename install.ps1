# Variables
$repoUrl = "https://github.com/yourusername/yourrepository.git"
$moduleDir = "HrolScripts"
$moduleFile = "HrolScripts.psd1"
$installLocation = Join-Path -Path $env:USERPROFILE -ChildPath "\Documents\_Development\PowerShell Modules\"
$fullInstallPath = Join-Path -Path $installLocation -ChildPath "$moduleDir\$moduleFile"

# Install git if not already installed
if (!(Get-Command git -errorAction SilentlyContinue)) {
    Write-Output "Installing Git..."
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco install git -y
}

# Clone the repository to the install location
Write-Output "Cloning repository..."
git clone $repoUrl $installLocation

# Append the PowerShell profile file to auto import cloned module
Write-Output "Adding module import to PowerShell profile..."
if (!(Test-Path $PROFILE)) {
    New-Item -Type file -Path $PROFILE -Force
}
$importCommand = "Import-Module `"$fullInstallPath`""
if (!((Get-Content -Path $PROFILE) -match $importCommand))
{
    Add-Content -Path $PROFILE -Value $importCommand
}

Write-Output "Module installed! Please restart your PowerShell session."