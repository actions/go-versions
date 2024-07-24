Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")
Import-Module (Join-Path $PSScriptRoot "../helpers/common-helpers.psm1")

Describe "Go" {

    BeforeAll {
    Set-Location -Path "source"
    $sourceLocation = Get-Location

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
}

    It "is available" {
        "go version" | Should -ReturnZeroExitCode
    }

    It "version is correct" {
        [version]$Version = $env:VERSION
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
        
        # GitHub Windows images don't have `AGENT_TOOLSDIRECTORY` variable
        $toolcacheDir = $env:AGENT_TOOLSDIRECTORY ?? $env:RUNNER_TOOL_CACHE
        $expectedPath = Join-Path -Path $toolcacheDir -ChildPath "go"
        $goPath.startsWith($expectedPath) | Should -BeTrue -Because "'$goPath' is not started with '$expectedPath'"
    }

    It "cached version is used without downloading" {
    
    if ($env:RUNNER_TYPE -eq "self-hosted") {
        # Get the installed version of Go
        $goVersion = Invoke-Expression "go version"
        # Check if Go is installed
        $goVersion | Should -Not -BeNullOrEmpty
        # Check if the installed version of Go is the expected version
        $installedVersion = $goVersion -split " " | Select-Object -Index 2
        $installedVersion = $installedVersion -replace "go", "" -replace "v", ""
        $expectedVersion = $env:VERSION -replace ".0", ""
        $installedVersion | Should -BeLike "$expectedVersion*"
    }else {
        # Analyze output of previous steps to check if Go was consumed from cache or downloaded
        $useGoLogFile = Get-UseGoLogs
        $useGoLogFile | Should -Exist
        $useGoLogContent = Get-Content $useGoLogFile -Raw
        $useGoLogContent | Should -Match "Found in cache"
    } 
}


    It "Run simple code" {
        $simpleLocation = Join-Path -Path $sourceLocation -ChildPath "simple"
        Set-Location -Path $simpleLocation
        "go run simple.go" | Should -ReturnZeroExitCode
        "go build simple.go" | Should -ReturnZeroExitCode
        $compiledPackageName = "simple"
        if ($IsWindows) { $compiledPackageName += ".exe" }
        (Resolve-Path "./$compiledPackageName").Path | Should -ReturnZeroExitCode
    }

    It "Run maps code" {
        $mapsLocation = Join-Path -Path $sourceLocation -ChildPath "maps"
        Set-Location -Path $mapsLocation
        "go run maps.go" | Should -ReturnZeroExitCode
        "go build maps.go" | Should -ReturnZeroExitCode
        $compiledPackageName = "maps"
        if ($IsWindows) { $compiledPackageName += ".exe" }
        (Resolve-Path "./$compiledPackageName").Path | Should -ReturnZeroExitCode
    }

    It "Run methods code" {
        $methodsLocation = Join-Path -Path $sourceLocation -ChildPath "methods"
        Set-Location -Path $methodsLocation
        "go run methods.go" | Should -ReturnZeroExitCode
        "go build methods.go" | Should -ReturnZeroExitCode
        $compiledPackageName = "methods"
        if ($IsWindows) { $compiledPackageName += ".exe" }
        (Resolve-Path "./$compiledPackageName").Path | Should -ReturnZeroExitCode
    }
}
