# Agent Guidelines for NixOS Dotfiles

## Build/Lint/Test Commands
- **Check flake**: `nix flake check ./nix`
- **Format code**: `alejandra .` (ALWAYS use alejandra before committing)
- **Format check**: `alejandra --check .`
- **Rebuild system**: `./rebuild.sh` (auto-detects system or uses $NIX_HOST)
- **Enter dev shell**: ASK USER PERMISSION before entering `nix develop` or `nix-shell`

## Code Style
- **Formatter**: Alejandra (configured in flake.nix:16)
- **Indentation**: 2 spaces (.editorconfig)
- **Nix conventions**: Use `let...in` for variable scoping, `inherit` for passing args
- **Module structure**: Each module takes `{config, pkgs, ...}` and returns attrset
- **Imports**: Follow nixpkgs for specialArgs pattern (`inherit me inputs`)

## Important Notes
- Never rebuild the entire system on another machine; always use `./rebuild.sh` for rebuilding
- System configs: wsl-devbox, darwin, k3s-node, master-node
- Main flake is in `nix/` subdirectory, not root
- Git hooks auto-installed via devShell.shellHook
- Use `nix flake check` before committing to catch issues early
