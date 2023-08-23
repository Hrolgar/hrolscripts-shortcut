. $PSScriptRoot\functions\GoTo.ps1
$setupStatusFilePath = Join-Path $env:APPDATA "HrolScripts\hrolconfig.json"

function LoadSetupData {
    # write-host "Loading setup data from $setupStatusFilePath"
    return Get-Content -Path $setupStatusFilePath | ConvertFrom-Json
}

function SaveSetupData {
    param($data)
    $data | ConvertTo-Json -Depth 1 | Set-Content -Path $setupStatusFilePath -Force
}

function AssertInitialized {
    if ($global:setupData.InitCompleted -eq $false) {
        Write-Host -ForegroundColor Red "HrolScripts is not initialized. Type 'HrolScripts --init' to initialize it."
        $false
    }
    $true
}


if ((Test-Path -LiteralPath $setupStatusFilePath) -and ((LoadSetupData).InitCompleted -eq $true)) {
    $global:setupData = LoadSetupData
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
            Write-Host -ForegroundColor Green "  HrolScripts --add - Add a new shortcut."
            Write-Host -ForegroundColor Green "  HrolScripts --list - List all available shortcuts."
            Write-Host -ForegroundColor Green "  HrolScripts --edit - Edit an existing shortcut."
            Write-Host -ForegroundColor Green "  HrolScripts --remove - Remove an existing shortcut."
            break
        }
        "--init" {
            Initialize-HrolScripts
            CreateFunctionsAndAliases
            break
        }
        "--add" {
            if (-not (AssertInitialized)) {
                return
            }
            AddShortcut
            CreateFunctionsAndAliases
            break
        }
        "--list" {
            if (-not (AssertInitialized)) {
                return
            }
            if ($null -eq $global:setupData.SetupPaths) {
                Write-Host -ForegroundColor Red "No shortcuts available. You might need to run 'HrolScripts --init' to initialize."
            }
            else {
                Write-Host -ForegroundColor Cyan "The following shortcuts are available:"
                foreach ($func in $global:setupData.SetupPaths.psobject.Properties) {
                    Write-Host -ForegroundColor Cyan "- goto-$($func.Name.ToLower())"
                }
            }
            break
        }
        "--edit" {
            if (-not (AssertInitialized)) {
                return
            }
            EditShortcut
            CreateFunctionsAndAliases
            break
        }
        "--remove" {
            if (-not (AssertInitialized)) {
                return
            }
            RemoveShortcut
            CreateFunctionsAndAliases
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
    if (!(Test-Path -Path $setupStatusFilePath)) {
        # File doesn't exist yet, creating new one
        New-Item -ItemType File -Path $setupStatusFilePath -Force | Out-Null
        # Creating content for the setupStatusFilePath as a hashtable
        $setupFileContent = @{
            "InitCompleted" = $false
            "SetupPaths"    = $null
        }
        
        SaveSetupData $global:setupFileContent
    }
    $content = Get-Content -Path $setupStatusFilePath | ConvertFrom-Json
    if ($null -eq $content.InitCompleted -or $content.InitCompleted -eq $false) {
        AddShortcut -fromInit $true
        $global:setupData.InitCompleted = $true
        $global:setupData | ConvertTo-Json -Depth 1 | Set-Content -Path $setupStatusFilePath -Force | Out-Null
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
        Write-Error "Shortcut path cannot be empty."  # Use Write-Error to highlight important failures
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
        if (-not (AssertInitialized)) {
            return
        }
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
    SaveSetupData $global:setupData
    $global:setupData = LoadSetupData
}

function EditShortcut {
    if (-not (AssertInitialized)) {
        return
    }
    $shortcutAlias = Read-Host "Enter the full name of the shortcut you want to edit"
    if (![string]::IsNullOrWhiteSpace($shortcutAlias)) {
        $shortcutName = $shortcutAlias.Replace('goto-', '')

        if ($shortcutName -in $global:setupData.SetupPaths.psobject.Properties.Name) {

            $newShortcutAlias = Read-Host "Enter the new full name of the shortcut (leave empty for no change)"
            if (![string]::IsNullOrWhiteSpace($newShortcutAlias)) {
                $newShortcutName = $newShortcutAlias.Replace('goto-', '')
            } else {
                $newShortcutName = $shortcutName
                $newShortcutAlias = $shortcutAlias
            }

            $editPath = Read-Host "Do you want to edit the path? (y/n)"
            if ($editPath -eq "y") {
                $newShortcutPath = Read-Host "Enter the new path of the shortcut"
            } else {
                $newShortcutPath = $global:setupData.SetupPaths.$shortcutName
            }

            if (![string]::IsNullOrWhiteSpace($newShortcutName) -and ![string]::IsNullOrWhiteSpace($newShortcutPath)) {
                # Remove the old property by creating a new object without it
                $newSetupPaths = New-Object PSObject -Property @{
                    $newShortcutName = $newShortcutPath
                }

                foreach ($prop in $global:setupData.SetupPaths.psobject.Properties) {
                    if ($prop.Name -ne $shortcutName) {
                        Add-Member -InputObject $newSetupPaths -Name $prop.Name -Value $prop.Value -MemberType NoteProperty -Force
                    }
                }

                $global:setupData.SetupPaths = $newSetupPaths

                # Save to persistent storage
                $global:setupData | ConvertTo-Json -Depth 1 | Set-Content -Path $setupStatusFilePath -Force

                # Update PowerShell session
                Remove-Alias -Name "$shortcutAlias"
                New-Alias -Name "$newShortcutAlias" -Value $newShortcutName -Force

                Write-Host -ForegroundColor Green "Shortcut '$shortcutAlias' has been updated to '$newShortcutAlias'."
            } else {
                Write-Host -ForegroundColor Red "New shortcut name or path cannot be empty."
            }
        } else {
            Write-Host -ForegroundColor Red "Shortcut '$shortcutAlias' doesn't exist."
        }
    } else {
        Write-Host -ForegroundColor Red "Shortcut name cannot be empty."
    }
    CreateFunctionsAndAliases
}

function RemoveShortcut {
    $shortcutAlias = Read-Host "Enter the full name of the shortcut you want to delete, e.g. 'goto-ProjectName'"
    if (![string]::IsNullOrWhiteSpace($shortcutAlias)) {
        $shortcutName = $shortcutAlias.Replace('goto-', '')

        if ($shortcutName -in $global:setupData.SetupPaths.psobject.Properties.Name) {

            $confirm = Read-Host "Are you sure you want to remove the shortcut '$shortcutAlias'? (y/n)"
            if ($confirm -eq "y") {
                # Remove the old property by creating a new object without it
                $newSetupPaths = New-Object PSObject

                foreach ($prop in $global:setupData.SetupPaths.psobject.Properties) {
                    if ($prop.Name -ne $shortcutName) {
                        Add-Member -InputObject $newSetupPaths -Name $prop.Name -Value $prop.Value -MemberType NoteProperty -Force
                    }
                }

                $global:setupData.SetupPaths = $newSetupPaths

                # Save to persistent storage
                $global:setupData | ConvertTo-Json -Depth 1 | Set-Content -Path $setupStatusFilePath -Force

                # Update PowerShell session
                Remove-Alias -Name "$shortcutAlias"

                Write-Host -ForegroundColor Green "Shortcut '$shortcutAlias' has been removed."
            }

        } else {
            Write-Host -ForegroundColor Red "Shortcut '$shortcutAlias' doesn't exist."
        }
    } else {
        Write-Host -ForegroundColor Red "Shortcut name cannot be empty."
    }
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

function CreateFunctionsAndAliases {
    $setupPaths = $global:setupData.SetupPaths | ConvertTo-Json -Depth 99 -Compress | ConvertFrom-Json -AsHashtable
    foreach ($path in $setupPaths.GetEnumerator()) {
        $functionName = "GoTo" + $path.Name
        $functionCode = @"
param([string] `$FolderName)  
goToProject -projectPath `"$($path.Value)`" -FolderName `$FolderName
"@
        New-Item -Path Function:Global:$functionName -Value $functionCode | Out-Null
        New-Alias -Name "goto-$($path.Name.ToLower())" -Value $functionName -Scope global -Force
    }
}

CreateFunctionsAndAliases