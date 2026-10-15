[← Overview](../README.md)

# Packaging and releases

## Share a local build

1. Build once using the [source build guide](building.md).
2. In Finder, right-click `dist/Window Snapper.app` and choose **Compress**.
3. Give the resulting ZIP to the recipient through an approved channel.
4. The recipient unzips it, moves the app into Applications, opens it, and grants Accessibility access.

The recipient needs no developer tools. Share a compatible build: the default build targets the builder's architecture, so an Apple Silicon build does not support Intel Macs. The declared minimum is macOS 13; cross-version compatibility has not yet been validated.

Local builds are ad hoc signed, not publisher-authenticated or notarized. For work or wider distribution, use IT-approved Developer ID signing and notarization. A downloaded ZIP may be blocked by macOS or managed policy. Do not disable security protections to install it. See [SECURITY.md](../SECURITY.md).

Maintainers can build a ZIP and SHA-256 checksum with `bash scripts/package-release.sh`. The script verifies the extracted app signature, executable permission, and included notices before it reports success. Upload the ZIP and checksum as GitHub Release assets; the generated files stay in ignored `dist/`, outside Git history. Use a new tag for each release and describe its architecture and signing status accurately.

## Publish a GitHub Release

1. Review and commit the source revision intended for release.
2. Run `bash scripts/package-release.sh` from the repository root. On a restricted build host, use the explicit SwiftPM workaround described in the [build guide](building.md#build-troubleshooting) only if needed.
3. On GitHub, open **Releases → Draft a new release**, choose a new version tag and the reviewed source commit, and describe compatibility and signing status.
4. Attach the generated `dist/Window-Snapper-<version>-<architecture>.zip` and matching `.sha256` file. Keep generated archives out of Git history.
5. Mark experimental builds as prereleases. Check the uploaded files and publish when ready.
6. Update the README download link and installation guide for the new release. Preserve earlier release assets so existing versioned links remain valid.

GitHub adds source archives automatically; those are different from the app ZIP you attach. A user downloading the prebuilt app needs no developer tools.

## Workplace distribution

For a verified distribution, use an approved Developer ID identity, Apple notarization, and release validation. See [signing and workplace security](../SECURITY.md#workplace-distribution). The current beta is ad hoc signed and not notarized. Publishing a GitHub release does not change that.
