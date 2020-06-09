using module "./builders/go-builder.psm1"

class WinGoBuilder : GoBuilder {
    <#
    .SYNOPSIS
    Ubuntu Go builder class.

    .DESCRIPTION
    Contains methods that required to build Ubuntu Go artifact from sources. Inherited from base NixGoBuilder.

    .PARAMETER platform
    The full name of platform for which Go should be built.

    .PARAMETER version
    The version of Go that should be built.

    #>

    [string] $InstallationTemplateName
    [string] $InstallationScriptName
    [string] $OutputArtifactName

    WinGoBuilder(
        [version] $version,
        [string] $platform,
        [string] $architecture
    ) : Base($version, $platform, $architecture) {
        $this.InstallationTemplateName = "win-setup-template.ps1"
        $this.InstallationScriptName = "setup.ps1"
        $this.OutputArtifactName = "go-$Version-$Platform-$Architecture.zip"
    }

    [void] ExtractBinaries($archivePath) {
        $extractTargetDirectory = Join-Path $this.TempFolderLocation "tempExtract"
        Extract-SevenZipArchive -ArchivePath $archivePath -OutputDirectory $extractTargetDirectory
        $goOutputPath = Get-Item $extractTargetDirectory\* | Select-Object -First 1 -ExpandProperty Fullname
        Move-Item -Path $goOutputPath\* -Destination $this.WorkFolderLocation
    }

    [void] CreateInstallationScript() {
        <#
        .SYNOPSIS
        Create Go artifact installation script based on specified template.
        #>

        $installationScriptLocation = New-Item -Path $this.WorkFolderLocation -Name $this.InstallationScriptName -ItemType File
        $installationTemplateLocation = Join-Path -Path $this.InstallationTemplatesLocation -ChildPath $this.InstallationTemplateName
        $installationTemplateContent = Get-Content -Path $installationTemplateLocation -Raw

        $variablesToReplace = @{
            "{{__VERSION__}}" = $this.Version;
            "{{__ARCHITECTURE__}}" = $this.Architecture;
        }

        $variablesToReplace.keys | ForEach-Object { $installationTemplateContent = $installationTemplateContent.Replace($_, $variablesToReplace[$_]) }
        $installationTemplateContent | Out-File -FilePath $installationScriptLocation
        Write-Debug "Done; Installation script location: $installationScriptLocation)"
    }

    [void] ArchiveArtifact() {
        $OutputPath = Join-Path $this.ArtifactFolderLocation $this.OutputArtifactName
        Create-SevenZipArchive -SourceFolder $this.WorkFolderLocation -ArchivePath $OutputPath -ArchiveType "zip"
    }
}
