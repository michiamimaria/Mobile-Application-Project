# Creates a GitHub repo from this folder, adds origin, and pushes (requires: gh auth login).
# Usage:
#   .\scripts\push-with-github-cli.ps1
#   .\scripts\push-with-github-cli.ps1 -RepoName "my-unique-name" -Private

param(
  [string]$RepoName = "mobilni-aplikacii",
  [switch]$Private
)

$ErrorActionPreference = "Stop"
$ghCandidates = @(
  "C:\Program Files\GitHub CLI\gh.exe",
  (Get-Command gh -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
) | Where-Object { $_ -and (Test-Path $_) }

$gh = $ghCandidates | Select-Object -First 1
if (-not $gh) {
  Write-Error "GitHub CLI (gh) not found. Install: winget install GitHub.cli"
}

& $gh auth status 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Log in first, then run this script again:"
  Write-Host "  & `"$gh`" auth login"
  exit 1
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

if (git remote get-url origin 2>$null) {
  Write-Host "Remote origin exists. Pushing current branch..."
  git push -u origin master
  exit 0
}

$visibility = if ($Private) { "--private" } else { "--public" }
& $gh repo create $RepoName $visibility --source=. --remote=origin --push
