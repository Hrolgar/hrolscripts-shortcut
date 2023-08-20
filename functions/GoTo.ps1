function goto {
    param(
        [string] $Path
    )

    if([string]::IsNullOrWhiteSpace($Path)) {
        Write-Host -ForegroundColor Red "Path cannot be empty."
        return
    }

    if (Test-Path -LiteralPath $Path) {
        Set-Location -Path $Path
    }
    else {
        Write-Host -ForegroundColor Red "Path does not exist."
    }
}
