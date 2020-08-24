using module "./builders/win-go-builder.psm1"
using module "./builders/nix-go-builder.psm1"

<#
.SYNOPSIS
Generate Go artifact.

.DESCRIPTION
Main script that creates instance of GoBuilder and builds of Go using specified parameters.

.PARAMETER Version
Required parameter. The version with which Go will be built.

.PARAMETER Architecture
Optional parameter. The architecture with which Go will be built. Using x64 by default.

.PARAMETER Platform
Required parameter. The platform for which Go will be built.

#>

param(
    [Parameter (Mandatory=$true)][version] $Version,
    [Parameter (Mandatory=$true)][string] $Platform,
    [string] $Architecture = "x64"
)

Import-Module (Join-Path $PSScriptRoot "../helpers" | Join-Path -ChildPath "nix-helpers.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "../helpers" | Join-Path -ChildPath "win-helpers.psm1") -DisableNameChecking

function Get-GoBuilder {
    <#
    .SYNOPSIS
    Wrapper for class constructor to simplify importing GoBuilder.

    .DESCRIPTION
    Create instance of GoBuilder with specified parameters.

    .PARAMETER Version
    The version with which Go will be built.

    .PARAMETER Platform
    The platform for which Go will be built.

    .PARAMETER Architecture
    The architecture with which Go will be built.

    #>

    param (
        [version] $Version,
        [string] $Architecture,
        [string] $Platform
    )

    $Platform = $Platform.ToLower()  
    if ($Platform -match 'win32') {
        $builder = [WinGoBuilder]::New($Version, $Platform, $Architecture)
    } elseif (($Platform -match 'linux') -or ($Platform -match 'darwin')) {
        $builder = [NixGoBuilder]::New($Version, $Platform, $Architecture)
    } else {
        Write-Host "##vso[task.logissue type=error;] Invalid platform: $Platform"
        exit 1
    }

    return $builder
}

### Create Go builder instance, and build artifact
$Builder = Get-GoBuilder -Version $Version -Platform $Platform -Architecture $Architecture
$Builder.Build()
