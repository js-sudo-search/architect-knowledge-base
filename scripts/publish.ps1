$RepoRoot = "E:\Sujata-Workspace\architect-knowledge-base"

$Incoming = Join-Path $RepoRoot "incoming"
$FundamentalFolder = "F3_Common_System_Design_Building_Blocks"
$Destination = Join-Path $RepoRoot "fundamentals\$FundamentalFolder\Sessions"

if (!(Test-Path $Incoming)) {
    Write-Host "Incoming folder not found."
    exit 1
}

if (!(Test-Path $Destination)) {
    Write-Host "Destination folder not found."
    exit 1
}

$Sessions = Get-ChildItem $Incoming -Directory -Filter "Session_*"

if ($Sessions.Count -eq 0) {
    Write-Host "No Session_xxx folders found in incoming."
    exit 0
}

foreach ($Session in $Sessions) {

    $Readme = Join-Path $Session.FullName "README.md"
    $Transcript = Join-Path $Session.FullName "Coaching_Transcript.html"

    if (!(Test-Path $Readme)) {
        Write-Host "$($Session.Name) is missing README.md"
        continue
    }

    if (!(Test-Path $Transcript)) {
        Write-Host "$($Session.Name) is missing Coaching_Transcript.html"
        continue
    }

    $Target = Join-Path $Destination $Session.Name

    if (Test-Path $Target) {
        Write-Host "$($Session.Name) already exists. Skipping."
        continue
    }

    Copy-Item $Session.FullName -Destination $Destination -Recurse
    Write-Host "Copied $($Session.Name)"
}

Set-Location $RepoRoot

if (-not (git status --porcelain)) {
    Write-Host "Nothing to commit."
    exit 0
}

$CommitMessage = Read-Host "Commit message"

git add .
git commit -m "$CommitMessage"
git push

$Delete = Read-Host "Delete processed folders from incoming? (Y/N)"

if ($Delete -match '^[Yy]$') {
    foreach ($Session in $Sessions) {
        if (Test-Path $Session.FullName) {
            Remove-Item $Session.FullName -Recurse -Force
        }
    }
    Write-Host "Incoming cleaned."
}

Write-Host "Done."
