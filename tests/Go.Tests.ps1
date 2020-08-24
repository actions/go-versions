param (
    [version] [Parameter (Mandatory = $true)] [ValidateNotNullOrEmpty()]
    $Version
)

Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")
Import-Module (Join-Path $PSScriptRoot "../helpers/common-helpers.psm1")

function Get-UseGoLogs {
    # GitHub Windows images don't have `HOME` variable
    $homeDir = $env:HOME ?? $env:HOMEDRIVE
    $logsFolderPath = Join-Path -Path $homeDir -ChildPath "runners/*/_diag/pages" -Resolve

    $useGoLogFile = Get-ChildItem -Path $logsFolderPath | Where-Object {
        $logContent = Get-Content $_.Fullname -Raw
        return $logContent -match "setup-go@v"
    } | Select-Object -First 1
    return $useGoLogFile.Fullname
}

Describe "Go" {
    It "is available" {
        "go version" | Should -ReturnZeroExitCode
    }

    It "version is correct" {
        $versionOutput = Invoke-Expression "go version"
        $versionOutput | Should -Match $Version
    }

    It "is used from tool-cache" {
        $goPath = (Get-Command "go").Path
        $goPath | Should -Not -BeNullOrEmpty
        
        # GitHub Windows images don't have `AGENT_TOOLSDIRECTORY` variable
        $toolcacheDir = $env:AGENT_TOOLSDIRECTORY ?? $env:RUNNER_TOOL_CACHE
        $expectedPath = Join-Path -Path $toolcacheDir -ChildPath "go"
        $goPath.startsWith($expectedPath) | Should -BeTrue -Because "'$goPath' is not started with '$expectedPath'"
    }

    It "cached version is used without downloading" {
        # Analyze output of previous steps to check if Go was consumed from cache or downloaded
        $useGoLogFile = Get-UseGoLogs
        $useGoLogFile | Should -Exist
        $useGoLogContent = Get-Content $useGoLogFile -Raw
        $useGoLogContent | Should -Match "Found cache"
    }
}