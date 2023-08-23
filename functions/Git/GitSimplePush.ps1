function GitSimplePush {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="Enter the commit message.")]
        [string]$CommitMessage
    )

    try {
        $branch = git rev-parse --abbrev-ref HEAD

        if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
            throw "Commit message cannot be empty."
        }

        $shortenedMessage = $CommitMessage.Substring(0, [Math]::Min(15, $CommitMessage.Length)) + "..."
        $confirm = Read-Host "Are you sure you want to push the commit message '$shortenedMessage' to branch '$branch'? (y/n)"

        if ($confirm -eq "y") {
            git add .
            git commit -m $CommitMessage
            git push origin $branch
            Write-Host "Changes pushed successfully."
        } else {
            Write-Host "Push operation aborted."
        }
    } catch {
        Write-Host "An error occurred: $_"
    }
}