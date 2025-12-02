class GoBuilder {
    <#
    .SYNOPSIS
    Base Go builder class.

    .DESCRIPTION
    Base Go builder class that contains general builder methods.

    .PARAMETER Version
    The version of Go that should be built.

    .PARAMETER Platform
    The platform of Go that should be built.

    .PARAMETER Architecture
    The architecture with which Go should be built.

    .PARAMETER TempFolderLocation
    The location of temporary files that will be used during Go package generation.

    .PARAMETER WorkFolderLocation
    The location of installation files.

    .PARAMETER ArtifactFolderLocation
    The location of generated Go artifact.

    .PARAMETER InstallationTemplatesLocation
    The location of installation script template. Using "installers" folder from current repository.

    #>

    [version] $Version
    [string] $Platform
    [string] $Architecture
    [string] $TempFolderLocation
    [string] $WorkFolderLocation
    [string] $ArtifactFolderLocation
    [string] $InstallationTemplatesLocation

    GoBuilder ([version] $version, [string] $platform, [string] $architecture) {
        $this.Version = $version
        $this.Platform = $platform
        $this.Architecture = $architecture

        $this.TempFolderLocation = [IO.Path]::GetTempPath()
        $this.WorkFolderLocation = Join-Path $env:RUNNER_TEMP "binaries"
        $this.ArtifactFolderLocation = Join-Path $env:RUNNER_TEMP "artifact"

        $this.InstallationTemplatesLocation = Join-Path -Path $PSScriptRoot -ChildPath "../installers"
    }

    [uri] GetBinariesUri() {
        <#
        .SYNOPSIS
        Get base Go URI and return complete URI for Go installation executable.
        #>

        $arch = ($this.Architecture -eq "x64") ? "amd64" : $this.Architecture
        $goPlatform = ($this.Platform -Match "win32") ? "windows" : $this.Platform
        $ArchiveType = ($this.Platform -Match "win32") ? "zip" : "tar.gz"
        If ($this.Version.Build -eq "0" -and $this.Version -lt "1.21.0") {
            $goVersion = "go$($this.Version.ToString(2))"
        } else {
            $goVersion = "go$($this.Version.ToString(3))"
        }

        $filename = "$goVersion.$goPlatform-$arch.$ArchiveType"

        return "https://go.dev/dl/$filename"
    }

    [string] Download() {
        <#
        .SYNOPSIS
        Download Go binaries into artifact location.
        #>

        $binariesUri = $this.GetBinariesUri()
        $targetFilename = [IO.Path]::GetFileName($binariesUri)
        $targetFilepath = Join-Path -Path $this.TempFolderLocation -ChildPath $targetFilename

        Write-Debug "Download binaries from $binariesUri to $targetFilepath"
        try {
            (New-Object System.Net.WebClient).DownloadFile($binariesUri, $targetFilepath)
        } catch {
            Write-Host "Error during downloading file from '$binariesUri'"
            exit 1
        }

        Write-Debug "Done; Binaries location: $targetFilepath"
        return $targetFilepath
    }

    [void] Build() {
        <#
        .SYNOPSIS
        Generates Go artifact from downloaded binaries.
        #>

        Write-Host "Create WorkFolderLocation and ArtifactFolderLocation folders"
        New-Item -Path $this.WorkFolderLocation -ItemType "directory"
        New-Item -Path $this.ArtifactFolderLocation -ItemType "directory"

        Write-Host "Download Go $($this.Version) [$($this.Architecture)] executable..."
        $binariesArchivePath = $this.Download()

        Write-Host "Unpack binaries to target directory"
        $this.ExtractBinaries($binariesArchivePath)

        Write-Host "Create installation script..."
        $this.CreateInstallationScript()

        Write-Host "Archive artifact"
        $this.ArchiveArtifact()
    }
}
