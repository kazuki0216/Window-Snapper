# Downloadable app package

Status: Implemented packaging; beta distribution
Updated: 2026-10-15

## Quick read

Added a downloadable-app workflow: a GitHub Release contains an app ZIP that users can extract and drag into Applications without installing developer tools. The initial release target is `v0.1.0-beta.1`, for Apple Silicon only. It is ad hoc signed and not Apple-notarized; macOS or workplace policy may block it.

The package was built and its extracted signature, executable permission, and notices were verified. Next: Developer ID signing, notarization, and broader compatibility validation before a workplace rollout.

## Changed surface

| Area | Source |
| --- | --- |
| Packaging | [Release script](../../scripts/package-release.sh) |
| Downloads and install | [README](../../README.md) |
| Signing disclosure | [Security notes](../../SECURITY.md) |
| Intended release | [v0.1.0-beta.1](https://github.com/kazuki0216/Window-Snapper/releases/tag/v0.1.0-beta.1) |

## Engineer details

### Design and flow

The release script runs the existing hardened build, reads the bundle version and Mach-O architecture, and writes a versioned ZIP using ditto. It preserves the top-level app directory and executable permissions while omitting local extended attributes and ACLs. It extracts the ZIP into a temporary workspace directory, validates the code signature, compares bundled notices, checks executable permission, and writes a SHA-256 checksum. Temporary extracted files are removed. Outputs remain in ignored `dist/`.

No application code changed, and no agents were delegated. Release assets are separate from GitHub's automatically generated source archives. A checksum detects mismatches; it does not authenticate the publisher or certify safety.

### Verification evidence

- `SWIFTPM_DISABLE_SANDBOX=1 bash scripts/package-release.sh` exited 0; the restricted host requires that explicit build sandbox workaround.
- Built and extracted app signatures both passed `codesign --verify --strict --verbose=2`.
- Bundled LICENSE, DISCLAIMER.md, and SECURITY.md matched source; the extracted executable retained execute permission.
- ZIP inspection listed only `Window Snapper.app` and its expected bundle contents.
- The executable string scan found no `/Users/`, `/private/var/`, or `/var/folders/` machine paths.
- `bash -n scripts/package-release.sh` and `git diff --check` passed.

### Limitations

Apple Silicon only; no Intel or cross-version compatibility run. No notarization, Developer ID signing, managed deployment, or first launch on a clean Mac was performed. No claim of automatic Gatekeeper acceptance. The app still requires user-approved Accessibility access and employer approval where applicable. No auto-updater or Homebrew cask is introduced.
