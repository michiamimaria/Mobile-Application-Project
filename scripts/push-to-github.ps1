# Usage (from repo root):
#   .\scripts\push-to-github.ps1 -RepoUrl "https://github.com/<you>/<repo>.git"
# Create an empty repo on GitHub first (no README/license if you want a clean first push).

param(
  [Parameter(Mandatory = $true)]
  [string]$RepoUrl
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

if (-not (Test-Path (Join-Path $repoRoot '.git'))) {
  Write-Error "Not a git repository: $repoRoot"
}

if (git remote get-url origin 2>$null) {
  git remote set-url origin $RepoUrl
  Write-Host "Updated remote origin -> $RepoUrl"
}
else {
  git remote add origin $RepoUrl
  Write-Host "Added remote origin -> $RepoUrl"
}

git push -u origin master
