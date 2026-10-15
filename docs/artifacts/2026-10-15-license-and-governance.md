# License, disclaimer, and main protection

Status: Implemented
Updated: 2026-10-15

## Quick read

Added the standard MIT License permitting reuse and modification with warranty and liability disclaimers. A separate notice explains the original author's voluntary, free-of-charge intent and the user's responsibility, subject to applicable law. No document claims to make lawsuits impossible or override nonwaivable legal rights.

Configured GitHub protection for `main`, including required owner review for contributors. Public cloning remains allowed; it grants no write access. The sole owner's administrative override remains available so the owner can maintain the project without self-approval. Next: seek qualified legal advice if jurisdiction-specific liability protection is needed.

## Changed surface

| Area | Source |
| --- | --- |
| License | [LICENSE](../../LICENSE) |
| Voluntary use, responsibility, limitations | [DISCLAIMER](../../DISCLAIMER.md) |
| Public notice | [README](../../README.md) |
| Contribution and access policy | [CONTRIBUTING](../../CONTRIBUTING.md) |
| Owner assignment | [CODEOWNERS](../../.github/CODEOWNERS) |
| Bundled notices | [Build script](../../scripts/build-app.sh) |

## Engineer details

### Decisions and flow

The MIT license is unmodified apart from its copyright holder and year. It permits commercial as well as noncommercial reuse; the author's personal intent is documented separately and does not change the license. Licensing grants rights to copies, not access to the upstream repository.

CODEOWNERS assigns all files to `@kazuki0216`. GitHub branch protection requires one approving code-owner review, dismisses stale approvals, requires resolved conversations, and disables force pushes and deletions for ordinary contributors. No status check is required because no CI check has been established. Admin enforcement is off: the current sole repository administrator can override the policy. Future administrators could also override it, and administrators can change protections. No agents were delegated.

### Evidence

- GitHub inspection confirmed a public personal repository with `kazuki0216` as the sole collaborator, with admin permission.
- GitHub's protection update returned one required review, code-owner review enabled, stale review dismissal enabled, resolved conversations enabled, force pushes/deletion disabled, and admin enforcement disabled.
- The app packaging command succeeded after adding notice resources; strict code signature verification passed. The final notice filenames are checked during handoff.
- Source/documentation checks include local Markdown links, whitespace, and staged secret patterns before publication. No application runtime behavior changed.

### Limits and follow-ups

This is not legal advice or a guarantee against claims. Enforceability depends on applicable law and facts. The repository is public; blocking cloning is incompatible with the intended public reuse workflow. CODEOWNERS alone does not enforce protection; GitHub settings do. No malicious-contributor simulation was performed. Workplaces must still review Accessibility permission and deployment policy. Signing/notarization remain separate from the license and branch protections.
