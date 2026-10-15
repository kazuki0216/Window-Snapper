# Notarized release workflow preparation

Status: Workflow implemented; certificate and authentication setup required
Updated: 2026-10-15

## Quick read

Prepared a signing, submission, stapling, and package-verification workflow for future notarized app downloads. The current GitHub beta is still ad hoc signed. Existing development and distribution identities were visible, but no Developer ID Application identity was available. Notarytool and stapler are installed.

Next: the Account Holder must create a Developer ID Application certificate and save valid notarization credentials in local Keychain before a real notarized release can be produced. No credentials, personal certificate details, private keys, or real account identifiers are added to source.

## Changed surface

| Area | Source |
| --- | --- |
| Signing and submission | [notarize-release.sh](../../scripts/notarize-release.sh) |
| Ticket-preserving packaging | [package-release.sh](../../scripts/package-release.sh) |
| One-time setup and recovery | [Notarization guide](../notarization.md) |
| Release guide | [Releases](../releases.md) |

## Engineer details

### Flow and decisions

The workflow requires an explicit Developer ID Application identity name and a local Keychain profile. It validates authentication before building, signs using the existing Hardened Runtime pipeline, submits an intermediate ZIP to Apple, requires Accepted status, staples the app, and packages the existing app without rebuilding. The notarized packaging mode verifies Developer ID authority, stapler validation, and Gatekeeper assessment both before archiving and after extraction. The default local packaging path still builds and verifies an ad hoc app.

Notarization uploads software to Apple; these network operations belong to the release process, not the installed app. No Apple credentials are accepted through repository files or hardcoded arguments. Local results use private permissions under ignored build directories. A timeout preserves results for status lookup and does not imply cancellation. No agents were delegated.

### Evidence and limits

- Shell syntax checks passed for both scripts.
- Running the notarization script without configuration failed before any build or upload, with an explicit missing identity message.
- Running notarized packaging against the current ad hoc build failed before archiving, with an explicit Developer ID Application requirement.
- The normal ad hoc packaging path completed successfully after the script change, including strict checks of the built and extracted app signatures, executable permission, and bundled notices.
- Live Developer ID signing, notarization submission, ticket stapling, extracted ticket validation, and clean-Mac first launch remain unverified because the required certificate/profile are not available.
- No Apple account was created or modified, no private key was exported, no iOS certificate was changed, and no replacement binary release was published.

### Follow-ups

Complete certificate and Keychain setup, execute the workflow with the correct team, and validate a freshly downloaded notarized build on another Mac. Use a new source version/tag and update public download and signing statements only after success. Notarization does not replace IT review or an independent security audit.
