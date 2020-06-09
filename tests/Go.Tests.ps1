param (
    [version] [Parameter (Mandatory = $true)] [ValidateNotNullOrEmpty()]
    $Version
)

Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")
Import-Module (Join-Path $PSScriptRoot "../helpers/common-helpers.psm1")

function Get-UseGoLogs {
    $logsFolderPath = Join-Path -Path $env:AGENT_HOMEDIRECTORY -ChildPath "_diag" | Join-Path -ChildPath "pages"

    $useGoLogFile = Get-ChildItem -Path $logsFolderPath | Where-Object {
        $logContent = Get-Content $_.Fullname -Raw
        return $logContent -match "GoTool"
    } | Select-Object -First 1
    return $useGoLogFile.Fullname
}

Describe "Go" {
    It "is available" {
        "go version" | Should -ReturnZeroExitCode
    }

    It "version is correct" {
        $versionOutput = Invoke-Expression -Command "go version"
        $finalVersion = $Version.ToString(3)
        If ($Version.Build -eq "0"){
            $finalVersion = $Version.ToString(2)
        }
        $versionOutput | Should -Match $finalVersion
    }

    It "is used from tool-cache" {
        $goPath = (Get-Command "go").Path
        $goPath | Should -Not -BeNullOrEmpty
        $expectedPath = Join-Path -Path $env:AGENT_TOOLSDIRECTORY -ChildPath "go"
        $goPath.startsWith($expectedPath) | Should -BeTrue -Because "'$goPath' is not started with '$expectedPath'"
    }

    It "cached version is used without downloading" {
        # Analyze output of previous steps to check if Go was consumed from cache or downloaded
        $useGoLogFile = Get-UseGoLogs
        $useGoLogFile | Should -Exist
        $useGoLogContent = Get-Content $useGoLogFile -Raw
        $useGoLogContent | Should -Match "Found tool in cache"
    }

    Set-Location -Path "source"
    $sourceLocation = Get-Location

    It "Run simple code" {
        $simpleLocation = Join-Path -Path $sourceLocation -ChildPath "simple"
        Set-Location -Path $simpleLocation
        "go run simple.go" | Should -ReturnZeroExitCode
        "go build simple.go" | Should -ReturnZeroExitCode
        "./simple" | Should -ReturnZeroExitCode
    }

    It "Run maps code" {
        $mapsLocation = Join-Path -Path $sourceLocation -ChildPath "maps"
        Set-Location -Path $mapsLocation
        "go run maps.go" | Should -ReturnZeroExitCode
        "go build maps.go" | Should -ReturnZeroExitCode
        "./maps" | Should -ReturnZeroExitCode
    }

    It "Run methods code" {
        $methodsLocation = Join-Path -Path $sourceLocation -ChildPath "methods"
        Set-Location -Path $methodsLocation
        "go run methods.go" | Should -ReturnZeroExitCode
        "go build methods.go" | Should -ReturnZeroExitCode
        "./methods" | Should -ReturnZeroExitCode
    }
}