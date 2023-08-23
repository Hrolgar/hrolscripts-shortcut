<#
    .SYNOPSIS
    Pushes the current branch to the remote repository.
    .DESCRIPTION
    Pushes the current branch to the remote repository.
#>

function GitSimplePush {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$CommitMessage
    )

    $branch = git rev-parse --abbrev-ref HEAD
    if ($CommitMessage -eq $null) {
        throw "Commit message cannot be null."
        return
    }
    $confirm = Read-Host "Are you sure you want to push $commitMessage with the commit message to $branch? (y/n)"

    if ($confirm -eq "y") {
        git commit -m $commitMessage
        git push origin $branch
    }
    git add .
    git commit -m $CommitMessage
    git push origin $branch
}
