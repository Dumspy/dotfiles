#!/usr/bin/env nix-shell
#! nix-shell -i bash -p git jq nodejs nix-prefetch-git
# Update script for dex package
# Usage: ./update.sh [commit-or-tag]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Get latest commit from main branch, or use provided ref
REF="${1:-$(git ls-remote https://github.com/dcramer/dex refs/heads/main | cut -f1)}"
echo "Updating to: $REF"

# Clone and generate package-lock.json
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

git clone --depth 1 https://github.com/dcramer/dex.git "$TEMP_DIR/dex"
cd "$TEMP_DIR/dex"
git fetch --depth 1 origin "$REF"
git checkout "$REF"

# Get version from package.json
VERSION=$(jq -r .version package.json)
echo "Version: $VERSION"

# Generate package-lock.json with all deps including optional peer deps
rm -rf node_modules
npm install --legacy-peer-deps
npm install hono --legacy-peer-deps  # Required peer dep for @modelcontextprotocol/sdk
cp package-lock.json "$SCRIPT_DIR/"

# Calculate source hash
echo "Calculating source hash..."
SRC_HASH=$(nix-prefetch-git --quiet https://github.com/dcramer/dex --rev "$REF" | jq -r .hash)

# Update hashes.json with dummy npm hash first
cat > "$SCRIPT_DIR/hashes.json" << EOF
{
  "version": "$VERSION",
  "rev": "$REF",
  "hash": "$SRC_HASH",
  "npmDepsHash": "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
}
EOF

# Build to get the real npm deps hash
cd "$SCRIPT_DIR/../.."
NPM_HASH=$(nix-build -E 'with import <nixpkgs> {}; callPackage ./packages/dex/package.nix { fetchNpmDepsWithPackuments = fetchNpmDeps; npmConfigHook = npmHooks.npmConfigHook; }' 2>&1 | grep "got:" | awk '{print $2}' || true)

if [ -n "$NPM_HASH" ]; then
  cat > "$SCRIPT_DIR/hashes.json" << EOF
{
  "version": "$VERSION",
  "rev": "$REF",
  "hash": "$SRC_HASH",
  "npmDepsHash": "$NPM_HASH"
}
EOF
  echo "Updated to $VERSION ($REF)"
  echo "Run: nix-build -E '...' to verify"
else
  echo "Failed to get npm deps hash. Check hashes.json and rebuild manually."
fi
