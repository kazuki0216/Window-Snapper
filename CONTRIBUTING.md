# Contributing and repository access

You may clone, fork, use, and modify Window Snapper under the [MIT License](LICENSE). Those permissions apply to your copies of the code; they do not grant write access to the original GitHub repository or a right to have changes accepted.

## Proposing changes

1. Fork the repository and create a feature branch.
2. Keep changes focused. Explain behavior changes and any impact on permissions, data handling, or signing.
3. Check your diff for credentials, signing material, personal data, and generated build output.
4. Open a pull request against `main` for maintainer review. Submissions are voluntary; acceptance and response times are not guaranteed.

By submitting a contribution, you represent that you have permission to submit it and agree for it to be distributed under this repository's MIT License. Do not submit confidential workplace code or data.

## Protection of main

`@kazuki0216` is the code owner for every file. The configured branch protection requires an approving code-owner review for contributor pull requests, dismisses stale approvals when changes are added, requires conversations to be resolved, and disallows force pushes and branch deletion for ordinary contributors.

The repository administrator retains GitHub's administrative override, including the ability to merge their own changes without self-approval. At configuration time, the owner is the only collaborator with write/admin access. Granting another account admin access would also let it override protection; do not grant that role to untrusted contributors. Administrators can change repository protections.

GitHub enforces repository settings, not this file or CODEOWNERS alone. Public repositories remain readable and clonable. Never share repository credentials to let someone contribute; use forks and pull requests.
