# Go for Actions
This repository contains the code and scripts that we use to prepare Go packages used in [virtual-environments](https://github.com/actions/virtual-environments) and accessible through the [setup-go](https://github.com/actions/setup-go) Action.  
The file [versions-manifest.json](./versions-manifest.json) contains the list of available and released versions.  

> Caution: this is prepared for and only permitted for use by actions `virtual-environments` and `setup-go` action.

**Status**: Currently under development and in use for beta and preview actions.  This repo is undergoing rapid changes.

Latest of LTS versions will be installed on the [virtual-environments](https://github.com/actions/virtual-environments) images.  Other versions will be pulled JIT using the [`setup-go`](https://github.com/actions/setup-go) action.

## Adding new versions
We are trying to prepare packages for new versions of Go as soon as they are released. Please open an issue if any versions are missing.

## Contribution
Contributions are welcome! See [Contributor's Guide](./CONTRIBUTING.md) for more details about contribution process and code structure
