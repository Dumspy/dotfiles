#!/usr/bin/env bash
set -euo pipefail

# Validate portable dotfiles output
# Usage: ./scripts/validate-portable.sh <portable-output-dir>

INPUT_DIR="${1:?Input directory required}"

echo "Validating portable output in $INPUT_DIR..."

errors=0
warnings=0

# Check 1: No Nix store paths
echo -n "Checking for Nix store paths... "
if grep -r "/nix/store/" "$INPUT_DIR" 2>/dev/null | grep -v "PORTABLE_" | grep -v ".git"; then
  echo "❌ Found Nix store paths!"
  ((errors++))
else
  echo "✓"
fi

# Check 2: No Nix-specific messages
echo -n "Checking for Nix-specific messages... "
if grep -r "managed by Nix\|rebuild\.sh" "$INPUT_DIR"/.config "$INPUT_DIR"/.zshrc 2>/dev/null; then
  echo "❌ Found Nix-specific messages!"
  ((errors++))
else
  echo "✓"
fi

# Check 3: TPM is configured
echo -n "Checking TPM configuration... "
if [[ ! -f "$INPUT_DIR/.config/tmux/tmux.conf" ]] || ! grep -q "tpm/tpm" "$INPUT_DIR/.config/tmux/tmux.conf"; then
  echo "❌ TPM not configured in tmux!"
  ((errors++))
else
  echo "✓"
fi

# Check 4: Scripts are executable
echo -n "Checking script permissions... "
if [[ -f "$INPUT_DIR/.local/bin/tmux-sessionizer" ]] && [[ ! -x "$INPUT_DIR/.local/bin/tmux-sessionizer" ]]; then
  echo "❌ tmux-sessionizer not executable!"
  ((errors++))
elif [[ -f "$INPUT_DIR/bootstrap.sh" ]] && [[ ! -x "$INPUT_DIR/bootstrap.sh" ]]; then
  echo "❌ bootstrap.sh not executable!"
  ((errors++))
else
  echo "✓"
fi

# Check 5: No hardcoded user paths
echo -n "Checking for hardcoded user paths... "
if grep -r "/home/user\|/Users/felix\.berger" "$INPUT_DIR"/.config "$INPUT_DIR"/.zshrc "$INPUT_DIR"/.gitconfig 2>/dev/null; then
  echo "❌ Found hardcoded user paths!"
  ((errors++))
else
  echo "✓"
fi

# Check 6: zsh plugins referenced correctly
echo -n "Checking zsh plugin references... "
if grep -q "ZSH_AUTOSUGGESTIONS_DIR" "$INPUT_DIR/.zshrc" 2>/dev/null; then
  echo "✓"
else
  echo "⚠️  Warning: zsh plugin directory variable not found"
  ((warnings++))
fi

# Check 7: Metadata files exist (optional - only warn if missing)
echo -n "Checking metadata files... "
if [[ ! -f "$INPUT_DIR/PORTABLE_SOURCE_SHA" ]] && [[ ! -f "$INPUT_DIR/PORTABLE_GENERATED_AT" ]]; then
  echo "⚠️  Warning: Metadata files not found (CI will add them)"
  ((warnings++))
else
  echo "✓"
fi

# Check 8: README exists
echo -n "Checking README... "
if [[ ! -f "$INPUT_DIR/README.md" ]]; then
  echo "❌ Missing README.md!"
  ((errors++))
else
  echo "✓"
fi

# Check 9: TPM plugin declarations present
echo -n "Checking TPM plugin declarations... "
if [[ -f "$INPUT_DIR/.config/tmux/tmux.conf" ]] && grep -q "set -g @plugin" "$INPUT_DIR/.config/tmux/tmux.conf"; then
  echo "✓"
else
  echo "⚠️  Warning: No TPM plugin declarations found"
  ((warnings++))
fi

# Check 10: Catppuccin theme configured
echo -n "Checking Catppuccin theme... "
if [[ -f "$INPUT_DIR/.config/tmux/tmux.conf" ]] && grep -q "@catppuccin_flavour" "$INPUT_DIR/.config/tmux/tmux.conf"; then
  echo "✓"
else
  echo "⚠️  Warning: Catppuccin theme not configured"
  ((warnings++))
fi

# Check 11: Starship config present
echo -n "Checking starship config... "
if [[ -f "$INPUT_DIR/.config/starship.toml" ]]; then
  echo "✓"
else
  echo "⚠️  Warning: starship.toml not found"
  ((warnings++))
fi

# Check 12: Neovim config present
echo -n "Checking neovim config... "
if [[ -d "$INPUT_DIR/.config/nvim" ]]; then
  echo "✓"
else
  echo "⚠️  Warning: nvim config directory not found"
  ((warnings++))
fi

# Summary
echo ""
echo "==========================================="
echo "Validation Summary:"
echo "==========================================="
echo "Errors:   $errors"
echo "Warnings: $warnings"
echo ""

if [[ $errors -eq 0 ]]; then
  echo "✓ All critical validations passed!"
  if [[ $warnings -gt 0 ]]; then
    echo "  (With $warnings warning(s) - review above)"
  fi
  exit 0
else
  echo "❌ Validation failed with $errors error(s)"
  echo ""
  echo "Please review the errors above and fix them before deploying."
  exit 1
fi
