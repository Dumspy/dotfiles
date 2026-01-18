# AGENTS.md

## Build & Commands
- **ALWAYS Rebuild with**: `./rebuild.sh` (auto-detects system or prompts)
- **Format**: `alejandra` (Nix formatter, available in devShell)
- **Dev shell**: `nix flake show` or `nix develop`

## Architecture
- **Type**: Declarative dotfiles/NixOS configuration management using Nix flakes
- **Targets**: macOS (nix-darwin), NixOS (WSL, k3s-node, master-node)
- **Key inputs**: nixpkgs, home-manager, nix-darwin, nixos-wsl, opnix (1Password secrets), opencode, agent-skills-nix
- **Structure**:
  - `/modules/system` → system-level configs (nix-darwin/nixos)
  - `/modules/home` → home-manager configs
  - `/hosts` → per-host configs (darwin, wsl-devbox, k3s-node, master-node)
  - `/skills` → custom agent skills
- **Secrets**: Managed via opnix (1Password CLI integration)
- **SSH**: WSL uses npiperelay for host SSH agent forwarding

## Code Style
- **Formatting**: 2-space indent (see .editorconfig)
- **Language**: Nix
- **Pattern**: Declarative modules with specialArgs for per-host customization
- **Config structure**: `mkDarwin` and `mkNixos` factory functions for system setup
- **User config**: Per-system `specialArgs` includes username, homePrefix, SSH publicKey
- **Imports**: Modular structure with explicit `imports` in module definitions
