#Requires -Version 5.1
<#
.SYNOPSIS
  Myskills installer for Windows.

.DESCRIPTION
  Installs skills from K-arch-droid/Myskills into an agent's skill directory.

.EXAMPLE
  irm https://raw.githubusercontent.com/K-arch-droid/Myskills/main/scripts/install.ps1 | iex

.EXAMPLE
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/K-arch-droid/Myskills/main/scripts/install.ps1))) -Agent qoder -Global

.EXAMPLE
  .\scripts\install.ps1 -Agent codex -List
#>
[CmdletBinding()]
param(
  [ValidateSet('qoder','qoderwork','claude','claude-code','codex','cursor','opencode','qwen','qwencode','windsurf','trae','roo','kiro','agents')]
  [string]$Agent,

  [ValidateSet('auto','global','project')]
  [string]$Scope = 'auto',

  [Alias('Global')]
  [switch]$ToGlobal,

  [Alias('Project')]
  [switch]$ToProject,

  [string]$Skill,
  [switch]$List,
  [switch]$DryRun,
  [switch]$Force,

  [string]$Repo = 'K-arch-droid/Myskills',
  [string]$Branch = 'main'
)

if ($ToGlobal)  { $Scope = 'global' }
if ($ToProject) { $Scope = 'project' }

$ErrorActionPreference = 'Stop'

$GlobalDirs = @{
  'qoder'       = Join-Path $HOME '.qoder/skills'
  'qoderwork'   = Join-Path $HOME '.qoderwork/skills'
  'claude'      = Join-Path $HOME '.claude/skills'
  'claude-code' = Join-Path $HOME '.claude/skills'
  'codex'       = Join-Path $HOME '.codex/skills'
  'cursor'      = Join-Path $HOME '.cursor/skills'
  'opencode'    = Join-Path $HOME '.config/opencode/skills'
  'qwen'        = Join-Path $HOME '.qwen/skills'
  'qwencode'    = Join-Path $HOME '.qwen/skills'
  'windsurf'    = Join-Path $HOME '.codeium/windsurf/skills'
  'trae'        = Join-Path $HOME '.trae/skills'
  'roo'         = Join-Path $HOME '.roo/skills'
  'kiro'        = Join-Path $HOME '.kiro/skills'
  'agents'      = Join-Path $HOME '.agents/skills'
}

$ProjectDirs = @{
  'qoder'       = '.qoder/skills'
  'qoderwork'   = '.qoder/skills'
  'claude'      = '.claude/skills'
  'claude-code' = '.claude/skills'
  'codex'       = '.codex/skills'
  'cursor'      = '.cursor/skills'
  'opencode'    = '.opencode/skills'
  'qwen'        = '.qwen/skills'
  'qwencode'    = '.qwen/skills'
  'windsurf'    = '.windsurf/skills'
  'trae'        = '.trae/skills'
  'roo'         = '.roo/skills'
  'kiro'        = '.kiro/skills'
  'agents'      = '.agents/skills'
}

# ------------------------------------------------------------------ source
$Src = $null

if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot '../skills'))) {
  $Src = (Resolve-Path (Join-Path $PSScriptRoot '../skills')).Path
}
else {
  $tmp = Join-Path ([IO.Path]::GetTempPath()) ("myskills-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null

  Write-Host "Downloading $Repo@$Branch ..."
  $git = Get-Command git -ErrorAction SilentlyContinue

  if ($git) {
    & $git.Source clone --depth 1 --branch $Branch "https://github.com/$Repo.git" (Join-Path $tmp 'repo') 2>&1 | Out-Null
    $Src = Join-Path $tmp 'repo/skills'
  }
  else {
    $zip = Join-Path $tmp 'repo.zip'
    $url = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    $folder = Get-ChildItem $tmp -Directory | Where-Object { $_.Name -ne 'repo' } | Select-Object -First 1
    if ($folder) { $Src = Join-Path $folder.FullName 'skills' }
  }
}

if (-not $Src -or -not (Test-Path $Src)) {
  Write-Error "skills directory not found. Source: $Src"
  exit 1
}

# --------------------------------------------------------------- discover
$AllSkills = Get-ChildItem $Src -Directory | Where-Object {
  Test-Path (Join-Path $_.FullName 'SKILL.md')
} | Select-Object -ExpandProperty Name

if (-not $AllSkills -or $AllSkills.Count -eq 0) {
  Write-Error "no skills found under $Src"
  exit 1
}

if ($List) {
  Write-Host "Available skills in ${Repo}:"
  foreach ($s in $AllSkills) {
    $md = Get-Content (Join-Path $Src "$s/SKILL.md") -Raw
    $desc = ''
    if ($md -match '(?m)^description:\s*(.+)$') { $desc = $Matches[1] }
    if ($desc.Length -gt 100) { $desc = $desc.Substring(0,100) + '...' }
    Write-Host ("  {0,-22} {1}" -f $s, $desc)
  }
  exit 0
}

# ----------------------------------------------------------------- target
if (-not $Agent) {
  foreach ($a in @('qoder','qoderwork','claude','codex','cursor','opencode','qwen','windsurf','trae','roo','kiro','agents')) {
    if (Test-Path $GlobalDirs[$a]) { $Agent = $a; break }
  }
}

if (-not $Agent) {
  Write-Error "Could not detect an installed agent. Re-run with -Agent <name>."
  exit 1
}

if ($Scope -eq 'auto') {
  $g = $GlobalDirs[$Agent]
  $p = $ProjectDirs[$Agent]
  if ((Test-Path $g) -and (Test-Path $p)) {
    Write-Host "Both user-level and project-level directories exist."
    Write-Host "  user:    $g"
    Write-Host "  project: $p"
    $ans = Read-Host 'Install to? [user/project]'
    if ($ans -match '^p') { $Scope = 'project' } else { $Scope = 'global' }
  }
  elseif (Test-Path $g) { $Scope = 'global' }
  elseif (Test-Path $p) { $Scope = 'project' }
  else { $Scope = 'global' }
}

if ($Scope -eq 'global') {
  $Dest = $GlobalDirs[$Agent]
} else {
  $Dest = $ProjectDirs[$Agent]
}

# ---------------------------------------------------------------- install
if ($Skill) {
  $Wanted = $Skill -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
} else {
  $Wanted = $AllSkills
}

Write-Host "Agent:  $Agent"
Write-Host "Scope:  $Scope"
Write-Host "Target: $Dest"
Write-Host "Skills: $($Wanted -join ' ')"
Write-Host ''

$installed = 0; $skipped = 0; $failed = 0

foreach ($s in $Wanted) {
  $s = $s.Trim()
  if (-not $s) { continue }

  $sourceDir = Join-Path $Src $s
  if (-not (Test-Path $sourceDir)) {
    Write-Host "  SKIP  $s (not found in repository)"
    $failed++
    continue
  }

  $targetDir = Join-Path $Dest $s
  if ((Test-Path $targetDir) -and -not $Force) {
    Write-Host "  SKIP  $s (already exists at $targetDir, use -Force to overwrite)"
    $skipped++
    continue
  }

  if ($DryRun) {
    Write-Host "  PLAN  $s -> $targetDir"
    $installed++
    continue
  }

  try {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Copy-Item -Path (Join-Path $sourceDir '*') -Destination $targetDir -Recurse -Force

    if (Test-Path (Join-Path $targetDir 'SKILL.md')) {
      Write-Host "  OK    $s -> $targetDir"
      $installed++
    } else {
      Write-Host "  FAIL  $s (SKILL.md missing after copy)"
      $failed++
    }
  } catch {
    Write-Host "  FAIL  $s ($($_.Exception.Message))"
    $failed++
  }
}

Write-Host ''
Write-Host "Installed: $installed   Skipped: $skipped   Failed: $failed"

if ($installed -gt 0 -and -not $DryRun) {
  Write-Host ''
  Write-Host 'Restart your agent to load the new skills.'
}

if ($failed -gt 0) { exit 1 }
