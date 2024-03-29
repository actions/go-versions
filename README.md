# Go for Actions
This repository contains the code and scripts that we use to prepare Go packages used in [runner-images](https://github.com/actions/runner-images) and accessible through the [setup-go](https://github.com/actions/setup-go) Action.  
The file [versions-manifest.json](./versions-manifest.json) contains the list of available and released versions.  

> Caution: this is prepared for and only permitted for use by actions `runner-images` and `setup-go` action.

**Status**: Currently under development and in use for beta and preview actions.  This repo is undergoing rapid changes.

Latest of LTS versions will be installed on the [runner-images](https://github.com/actions/runner-images) images. Other versions will be pulled JIT using the [`setup-go`](https://github.com/actions/setup-go) action.

## Adding new versions
We are trying to prepare packages for new versions of Go as soon as they are released. Please open an issue in [actions/runner-images](https://github.com/actions/runner-images) if any versions are missing.

## Support Notification Policy
Beginning **approximately six months prior** to the removal of a Go version from the [versions-manifest.json](https://github.com/actions/go-versions/blob/main/versions-manifest.json) file, a pinned issue will be created in the [setup-go](https://github.com/actions/setup-go) repository. This pinned issue will provide important details about the upcoming end of support, including the specific date, as well as any other notes, relevant updates or alternatives. We encourage users to regularly check pinned issues for updates on tool versions they are using for maximum transparency, security, performance and overall compatibility with their projects.

## Contribution
Contributions are welcome! See [Contributor's Guide](./CONTRIBUTING.md) for more details about contribution process and code structure
