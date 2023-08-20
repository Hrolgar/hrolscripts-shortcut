$setupStatusFilePath = Join-Path $env:APPDATA "HrolScripts\hrolconfig.json"
if ($alreadyInitialized -eq $true) {
    Write-Host -ForegroundColor Green "Script successfully reloaded!"
    return
}
if ((Test-Path -LiteralPath $setupStatusFilePath) -and ((Get-Content -Path $setupStatusFilePath | ConvertFrom-Json).InitCompleted -eq $true)) {
    $global:setupData = Get-Content -Path $setupStatusFilePath | ConvertFrom-Json
    Write-Host -ForegroundColor Green "HrolScripts is Initialized! Welcome back!`n For more information, type 'HrolScripts --help'"
}
else {
    $global:setupData = @{
        InitCompleted = $false
        SetupPaths    = @{}
    }
    Write-Host -ForegroundColor Yellow "Warning: HrolScripts is not initialized. Type 'HrolScripts --init' to initialize it."
}
function HrolScripts {
    $command = $args[0]

    switch ($command) {
        "--help" {
            Write-Host "Welcome to HrolScripts! This module -------."
            Write-Host "You can use the following commands:"
            Write-Host -ForegroundColor Green "  HrolScripts-Init - Initialize the module and perform the first-time setup."
            Write-Host -ForegroundColor Green "  HrolScripts --help - Show this help message."
            break
        }
        "--init" {
            Initialize-HrolScripts
            break
        }
        "--add" {
            AddShortcut
            break
        }
        default {
            # Make the text red
            Write-Host -ForegroundColor Red "Unknown command '$command'. Type 'HrolScripts --help' for help."
            break
        }
    }
}

function Initialize-HrolScripts {
    $content = Get-Content -Path $setupStatusFilePath | ConvertFrom-Json
    if ($null -eq $content.InitCompleted -or $content.InitCompleted -eq $false) {
        AddShortcut -fromInit $true
        $global:setupData.InitCompleted = $true
        $global:setupData | ConvertTo-Json -Depth 1 | Set-Content -Path $setupStatusFilePath -Force
        Write-Host -ForegroundColor Green "Welcome to HrolScripts! First time setup completed."
    }
    else {
        Write-Host -ForegroundColor Yellow "HrolScripts is already initialized. If you want to add a new shortcut, type 'HrolScripts --add'"
    }

}

function _Setup {
    param(
        [bool] $fromInit = $false
    )
    $shortcutName = Read-Host "Enter the name of the shortcut"
    if ([string]::IsNullOrWhiteSpace($shortcutName)) {
        return
    }
    $shortcutPath = Read-Host "Enter the path of the $shortcutName folder"
    if ([string]::IsNullOrWhiteSpace($shortcutPath)) {
        return
    }

    if ($fromInit) {
        $global:setupData.SetupPaths[$shortcutName] = $shortcutPath
        return
    }
    Add-Member -InputObject $global:setupData.SetupPaths -Name $shortcutName -Value $shortcutPath -MemberType NoteProperty -Force
    return
}

function AddShortcut {
    param(
        [bool] $fromInit = $false
    )
    if ($fromInit) {
        _Setup -fromInit $true
        $global:setupData | ConvertTo-Json -Depth 1 | Set-Content -Path $setupStatusFilePath -Force
        $global:setupData = Get-Content -Path $setupStatusFilePath | ConvertFrom-Json

        return
    }
    elseif ($global:setupData.InitCompleted -eq $true) {
        while ($true) {
            _Setup

            $continue = Read-Host "Do you want to add another shortcut? (y/n)"
            if ($continue -eq "n") {
                break
            }
        }
    }
    else {
        Write-Host -ForegroundColor Red "HrolScripts is not initialized. Type 'HrolScripts --init' to initialize it."
    }
    $global:setupData | ConvertTo-Json -Depth 1 | Set-Content -Path $setupStatusFilePath -Force
    $global:setupData = Get-Content -Path $setupStatusFilePath | ConvertFrom-Json
}

function goToProject {
    param(
        [string] $projectPath,
        [string] $folderName
    )

    $shouldList = $folderName.EndsWith("!")
    $expandedPath = Join-Path $projectPath $folderName.TrimEnd("!")

    if ($expandedPath -and (Test-Path -LiteralPath $expandedPath)) {
        Set-Location -Path $expandedPath
    }
    else {
        Write-Host -ForegroundColor Red "$projectType folder path is not set or does not exist."
    }

    if ($shouldList) {
        Get-ChildItem
    }
}

$setupPaths = $global:setupData.SetupPaths | ConvertTo-Json -Depth 99 -Compress | ConvertFrom-Json -AsHashtable

foreach ($path in $setupPaths.GetEnumerator()) {
    Write-Host -ForegroundColor Green "Creating function for "$path.Name
    $functionName = "GoTo" + $path.Name
    $functionCode = @"
function $functionName {
    param([string] `$FolderName)  
    goToProject -projectPath `"$($path.Value)`" -FolderName `$FolderName
}
"@
    Invoke-Expression $functionCode
    New-Alias -Name "goto-$($path.Name.ToLower())" -Value $functionName -Force
}

