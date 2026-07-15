$RepoRoot = "E:\Sujata-Workspace\architect-knowledge-base"

$Incoming = Join-Path $RepoRoot "incoming"
$Fundamentals = Join-Path $RepoRoot "Fundamentals"

if (!(Test-Path $Incoming)) {
    Write-Host "Incoming folder not found."
    exit 1
}

# ---------------------------------------------------------
# Find downloaded packages
# ---------------------------------------------------------

$Packages = Get-ChildItem $Incoming -Directory

if ($Packages.Count -eq 0) {
    Write-Host "No package found in incoming."
    exit 0
}

foreach ($Package in $Packages)
{
    Write-Host ""
    Write-Host "======================================="
    Write-Host "Processing Package:"
    Write-Host $Package.Name
    Write-Host "======================================="

    # Find F1_*, F2_* etc.
    $Fundamental = Get-ChildItem $Package.FullName -Directory |
        Where-Object { $_.Name -match "^F\d+_" }

    if ($null -eq $Fundamental)
    {
        Write-Host "No Fundamental folder found."
        continue
    }

    Write-Host ""
    Write-Host "Fundamental:"
    Write-Host $Fundamental.Name

    $Destination = Join-Path $Fundamentals $Fundamental.Name

    if (!(Test-Path $Destination))
    {
        New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    }

    #
    # Copy Sessions
    #

    $SourceSessions = Join-Path $Fundamental.FullName "Sessions"

    if (Test-Path $SourceSessions)
    {
        Write-Host ""
        Write-Host "Publishing Sessions..."

        Copy-Item `
            "$SourceSessions\*" `
            (Join-Path $Destination "Sessions") `
            -Recurse `
            -Force

        Write-Host "Sessions updated."
    }

    #
    # Copy Chapters
    #

    $SourceChapters = Join-Path $Fundamental.FullName "Chapters"

    if (Test-Path $SourceChapters)
    {
        Write-Host ""
        Write-Host "Publishing Chapters..."

        Copy-Item `
            "$SourceChapters\*" `
            (Join-Path $Destination "Chapters") `
            -Recurse `
            -Force

        Write-Host "Chapters updated."
    }
}

#
# Git
#

Set-Location $RepoRoot

git add .

if (-not (git status --porcelain))
{
    Write-Host ""
    Write-Host "Nothing to commit."
    exit 0
}

$CommitMessage = Read-Host "Commit message"

git commit -m "$CommitMessage"

git push

#
# Cleanup
#

$Delete = Read-Host "Delete processed packages from incoming? (Y/N)"

if ($Delete -match '^[Yy]$')
{
    foreach ($Package in $Packages)
    {
        Remove-Item $Package.FullName -Recurse -Force
    }

    Write-Host ""
    Write-Host "Incoming cleaned."
}

Write-Host ""
Write-Host "======================================="
Write-Host "Publish completed successfully."
Write-Host "======================================="