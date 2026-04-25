# Dotfiles Cleanup Plan (Without clan-core)

This is the smaller, safer reorganization plan. It fixes the "hectic" feeling without changing deployment tools or the overall architecture.

## Problem Statement

The repo feels messy because of:
1. Monolithic `flake.nix` (~300 lines) with inline deploy-rs, all systems, devShell, and checks
2. `hosts/` mixes shared and per-host configs at the same level
3. Host metadata duplicated across `flake.nix`, `deploy.sh`, and `rebuild.sh`
4. Redundant imports in per-host `home.nix` files
5. `oci-keepalive.nix` imported via relative path, bypassing the module system
6. `AGENTS.md` references non-existent paths

## Changes

### 1. Restructure `hosts/` Directory

Move shared base configs into `hosts/common/`:

```
hosts/
  common/
    config.nix      # was hosts/config.nix
    system.nix      # was hosts/system.nix
    home.nix        # was hosts/home.nix
  darwin/
  wsl-devbox/
  oci-node-1/
  oci-node-2/
  oci-node-3/
  k3s-node/
  master-node/
```

Update `lib/default.nix` to import from `hosts/common/`.

### 2. Extract Deployment from `flake.nix`

Move inline deploy-rs config to `nix/deploy.nix`. `flake.nix` should only orchestrate.

### 3. Single Source of Truth for Hosts

Create `lib/hosts.nix`:

```nix
{
  darwin = { type = "darwin"; system = "aarch64-darwin"; };
  wsl-devbox = { type = "nixos"; system = "x86_64-linux"; isWsl = true; };
  oci-node-1 = { type = "nixos"; system = "aarch64-linux"; ip = "100.99.30.112"; deployUser = "deploy"; };
  oci-node-2 = { type = "nixos"; system = "aarch64-linux"; ip = "100.120.122.114"; deployUser = "deploy"; };
  oci-node-3 = { type = "nixos"; system = "aarch64-linux"; ip = "100.64.54.67"; deployUser = "deploy"; };
  k3s-node = { type = "nixos"; system = "x86_64-linux"; ip = "100.109.48.72"; deployUser = "deploy"; };
  master-node = { type = "nixos"; system = "x86_64-linux"; ip = "100.83.126.36"; deployUser = "deploy"; };
}
```

Update `flake.nix`, `nix/deploy.nix`, `deploy.sh`, and `rebuild.sh` to consume this.

### 4. Fix Redundant Imports

Remove `imports = [ ../config.nix ../home.nix ]` from per-host home.nix files.

### 5. Remove `oci-keepalive.nix`

Remove the file and its import from `hosts/oci-node-1/system.nix`.

### 6. Fix Documentation

- Update `AGENTS.md` paths (`ai/skills/` not `/skills`)
- Add `lib/README.md` explaining factory functions

### 7. Tooling

- Add `deadnix` to devshell
- Keep `alejandra` as formatter (no `treefmt-nix`)

## Result

- `flake.nix` is slimmed down to ~100 lines
- Adding a new host means editing exactly 2 files: `lib/hosts.nix` + `hosts/<name>/`
- No redundant imports
- All modules go through the standard import chain
- No new tools or frameworks to learn

## Deliverables

- [ ] `hosts/common/` created
- [ ] `lib/hosts.nix` created
- [ ] `nix/deploy.nix` created
- [ ] `flake.nix` slimmed down
- [ ] Redundant imports removed
- [ ] `oci-keepalive.nix` removed
- [ ] `AGENTS.md` fixed
- [ ] `deadnix` added to devshell
