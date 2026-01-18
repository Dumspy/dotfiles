#!/usr/bin/env bash

set -euo pipefail

# Dependabot Solver Script
# Fetches open Dependabot alerts and returns package info for LLM resolution

STRATEGY="${1:-consolidated}"
BASE_BRANCH="${2:-main}"

usage() {
  cat <<EOF
Usage: dependabot-solver.sh [STRATEGY] [BASE_BRANCH]

Arguments:
  STRATEGY       'consolidated' (single PR for all) or 'individual' (one per alert) [default: consolidated]
  BASE_BRANCH    Target branch [default: main]

Environment:
  Must be run in an already-cloned repository with git remote 'origin'

Examples:
  dependabot-solver.sh
  dependabot-solver.sh individual main

Output:
  JSON object with alerts and resolution info
EOF
  exit 1
}

if [[ "$STRATEGY" == "-h" || "$STRATEGY" == "--help" ]]; then
  usage
fi

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Error: Not in a git repository" >&2
  exit 1
fi

# Get repo from git
REPO=$(git config --get remote.origin.url | sed 's|.*github.com[:/]\(.*\)\.git$|\1|' || echo "")
if [[ -z "$REPO" ]]; then
  echo "❌ Error: Could not determine repository URL" >&2
  exit 1
fi

# Detect package manager
detect_package_manager() {
  if [[ -f "package.json" ]]; then
    echo "npm"
  elif [[ -f "yarn.lock" ]]; then
    echo "yarn"
  elif [[ -f "pnpm-lock.yaml" ]]; then
    echo "pnpm"
  elif [[ -f "Gemfile.lock" ]]; then
    echo "bundler"
  elif [[ -f "Cargo.lock" ]]; then
    echo "cargo"
  elif [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]] || [[ -f "pyproject.toml" ]]; then
    echo "pip"
  elif [[ -f "go.mod" ]]; then
    echo "go"
  else
    echo "unknown"
  fi
}

PKG_MANAGER=$(detect_package_manager)

echo "🔍 Fetching Dependabot alerts for $REPO..." >&2

# Fetch open Dependabot alerts with full details
ALERTS=$(gh api "repos/$REPO/dependabot/alerts" \
  -f state=open \
  --jq '.[] | {
    number: .number,
    package_name: .dependency.package.name,
    ecosystem: .dependency.package.ecosystem,
    severity: .security_advisory.severity,
    summary: .security_advisory.summary,
    description: .security_advisory.description,
    vulnerabilities: [.security_fixes[] | {
      vulnerable_version_range: .vulnerable_version_range,
      patched_versions: .versions
    }],
    current_version: .dependency.manifest_path
  }' 2>/dev/null || echo "[]")

ALERT_COUNT=$(echo "$ALERTS" | jq 'length')
echo "Found $ALERT_COUNT Dependabot alert(s)" >&2

# Output structured JSON with strategy
OUTPUT=$(jq -n \
  --arg repo "$REPO" \
  --arg strategy "$STRATEGY" \
  --arg base_branch "$BASE_BRANCH" \
  --arg pkg_manager "$PKG_MANAGER" \
  --argjson alerts "$(echo "$ALERTS")" \
  '{
    repository: $repo,
    strategy: $strategy,
    base_branch: $base_branch,
    package_manager: $pkg_manager,
    alert_count: ($alerts | length),
    alerts: $alerts
  }')

echo "$OUTPUT"
