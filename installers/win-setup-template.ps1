$ErrorActionPreference = "Stop"

[version]$Version = "{{__VERSION__}}"
[string]$Architecture = "{{__ARCHITECTURE__}}"

$ToolcacheRoot = $env:AGENT_TOOLSDIRECTORY
if ([string]::IsNullOrEmpty($ToolcacheRoot)) {
    # GitHub images don't have `AGENT_TOOLSDIRECTORY` variable
    $ToolcacheRoot = $env:RUNNER_TOOL_CACHE
}
$GoToolcachePath = Join-Path -Path $ToolcacheRoot -ChildPath "go"
$GoToolcacheVersionPath = Join-Path -Path $GoToolcachePath -ChildPath $Version.ToString()
$GoToolcacheArchitecturePath = Join-Path $GoToolcacheVersionPath $Architecture

Write-Host "Check if Go hostedtoolcache folder exist..."
if (-not (Test-Path $GoToolcachePath)) {
    New-Item -ItemType Directory -Path $GoToolcachePath | Out-Null
}

Write-Host "Delete Go $Version if installed"
if (Test-Path $GoToolcacheVersionPath) {
    Remove-Item $GoToolcachePath -Recurse -Force | Out-Null
}

Write-Host "Create Go $Version folder"
if (-not (Test-Path $GoToolcacheArchitecturePath)) {
    New-Item -ItemType Directory -Path $GoToolcacheArchitecturePath | Out-Null
}

Write-Host "Copy Go binaries to hostedtoolcache folder"
Copy-Item -Path * -Destination $GoToolcacheArchitecturePath -Recurse
Remove-Item $GoToolcacheArchitecturePath\setup.ps1 -Force | Out-Null

Write-Host "Create complete file"
New-Item -ItemType File -Path $GoToolcacheVersionPath -Name "$Architecture.complete" | Out-Null