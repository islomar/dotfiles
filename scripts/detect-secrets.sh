#!/bin/bash
#
# Rejects a commit when gitleaks finds a secret in the staged changes. Findings are redacted.
# False positive: add a .gitleaksignore file at the repository root, or skip with git commit --no-verify.
#
set -euo pipefail

if ! command -v gitleaks >/dev/null 2>&1; then
	echo "⚠️  gitleaks is not installed: staged changes were not scanned for secrets (brew install gitleaks)." >&2
	exit 0
fi

gitleaks git --staged --pre-commit --redact --no-banner --log-level warn --verbose
