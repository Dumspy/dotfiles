# Comparative Review: dotfiles vs Mic92/dotfiles

## Executive Summary

This report compares your dotfiles setup against Mic92/dotfiles (Joerg's), a well-established, production-grade NixOS configuration. The goal is to surface actionable improvements.

---

## 1. Architecture Comparison

| Aspect | Your dotfiles | Mic92/dotfiles |
|--------|-------------|----------------|
| **Flake orchestration** | `flake-utils.lib.eachDefaultSystem` | `adios-flake.lib.mkFlake` |
| **Machine definition** | Factory functions in `lib/default.nix` | `clan-core.lib.clan` (inventory-based) |
| **Module structure** | `modules/system`, `modules/home`, `hosts/` | `nixosModules/`, `home-manager/`, `machines/` |
| **Host patterns** | Per-host `hosts/{name}/system.nix` | Per-host `machines/{name}/configuration.nix` |
| **Multi-system support** | Manual factory functions | Declarative via `clan-core` |
| **Nixpkgs source** | `nixpkgs-unstable` (NixOS/nixpkgs) | Forked at `github:Mic92/nixpkgs` |

### Key Differences

1. **Clan-based inventory** — Mic92 uses `clan-core` for declarative machine/tag/instance management, enabling:
   - Tag-based deployments (e.g., `backup = builtins.filter (...) config.nixos`)
   - Cross-machine role definitions (e.g., `zerotier-mic92` with controllers/peers)
   - Instance abstraction (borgbackup, wireguard, users)

2. **Custom nixpkgs fork** — Mic92 maintains his own nixpkgs fork with upstream patches, enabling kernel/boot customization.

3. **Adios-flake** — Provides standardized module interface with per-system checks, devShells, and package outputs.

### Your Takeaways

- **Consider `clan-core`** for multi-machine deployments — it abstracts deployment patterns (SSH, remote build, tags)
- **Your factory pattern** (`mkDarwin`/`mkNixos`) is simpler and easier to understand — good for personal use
- Mic92's architecture shines at scale (10+ machines with complex interconnections)

---

## 2. Package Management

### Your Packages

Core utilities: `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `zoxide`, `lazygit`, `direnv`, `nix-output-monitor`, `ghostty`, `fish`, `tmux`

Niche tools: `lazyvim`, `dex`, `agent-browser`, `anthropics-agent-skills`, `vercel-agent-skills`, `expo-agent-skills`, `llm-agents`, `catppuccin`

### Mic92 Packages

Core utilities: Same (`eza`, `bat`, `fd`, `fzf`, `lazygit`, `direnv`, `nix-direnv`)

Niche tools: Custom-built tools exported as packages:

```
pkgs/flake-module.nix:
- forge-triage
- merge-when-green
- claude-code
- n8n-hooks
- email-sync
- msmtp-with-sent
- claude-md
- crabfit-cli
- gh-radicle
- iroh-ssh
- ghidra-cli
- rbw-pinentry
- calendar-bot
- nix-eval-warnings
- kimai-cli
- pi, pim (AI tools)
```

### Key Differences

| Aspect | Your dotfiles | Mic92 |
|--------|-------------|------|
| **Custom packages** | None (uses upstream) | ~25+ custom packages in repo |
| **AI tool integration** | External skill packages, `llm-agents` | Built via `llm-agents.nix` input + custom wrappers |
| **Package pinning** | Implicit via flake inputs | Explicit via `nixpkgs` fork |
| **Shell** | `fish` (with pure prompt) | `zsh` (with homeshick) |
| **Dev tooling** | `treefmt-nix` via pre-commit | `treefmt-nix` + `deadnix` + `stylua` + `ruff` + `deno` |

### Your Takeaways

1. **Package development** — Your dotfiles imports AI skills externally; Mic92 builds and exports packages. Consider wrapping tools you use often.
2. **Shell choice** — You're on `fish`; Mic92 uses `zsh`. Both work well; fish has better interactive ergonomics out of the box.
3. **Formatter suite** — Mic92 has richer devshell tooling (deadnix, stylua, ruff-check, deno). Consider adding `deadnix` for linting.

---

## 3. Secrets & Keys

| Aspect | Your dotfiles | Mic92 |
|--------|-------------|------|
| **Secrets** | `opnix` (1Password-backed) | `sops-nix` with `age` |
| **Key file** | Managed via opnix | `darwinModules/sops.nix` (age-key.txt) |

### Your Takeaways

- **Opnix** provides 1Password integration — more convenient if you already use 1Password
- **sops-nix** is the community standard — better interoperability with other dotfiles repos

---

## 4. Testing & CI

| Aspect | Your dotfiles | Mic92 |
|--------|-------------|------|
| **Pre-commit** | `alejandra` via git-hooks | `treefmt-nix` via devshell |
| **Formatter check** | `alejandra` only | `treefmt-nix` (alejandra + deadnix + ruff + deno + shellcheck + shfmt) |
| **Checks** | Per-system `pre-commit-check` | Full `checks/flake-module.nix` (nixos + darwin + packages + tests + devShells) |
| **CI** | Not visible | Renovation for automated updates |

### Your Takeaways

1. **Add deadnix** — Finds unused bindings in Nix code
2. **Add renovate** — Automated dependency updates for flake inputs
3. **Comprehensive checks** — Mic92's check generation per machine/package/test/devShell is mature; your approach is simpler

---

## 5. Nix Configuration

### Your Nix Settings

None explicit (relies on defaults).

### Mic92's Nix Settings

```nix
nixConfig.extra-substituters = [ "https://cache.thalheim.io" ];
nixConfig.extra-trusted-public-keys = [ "cache.thalheim.io-1:..." ];
```

Plus custom Nix fork with:
- Experimental features (flakes, nix-command)
- Custom eval optimizations

### Your Takeaways

- Consider adding **extra substituters** for faster builds (e.g., cachix)
- Mic92's custom Nix fork is advanced — only pursue if you need specific upstream patches

---

## 6. Deployments

| Aspect | Your dotfiles | Mic92 |
|--------|-------------|------|
| **Remote deployment** | `deploy-rs` | `clan-core` deploy + remote builders |
| **OCI support** | OCI nodes (aarch64-linux) | Not present |
| **macOS support** | nix-darwin (single) | Multiple darwin machines |
| **WSL support** | nixos-wsl | Not present |

### Your Takeaways

- **deploy-rs** is solid for OCI — you're well-configured there
- **clan** adds remote build orchestration — more complex but powerful for heterogeneous fleets

---

## 7. Recommendations

### High Priority

1. **Add deadnix** to devshell for unused binding detection
   ```nix
   # In devshell
   pkgs.deadnix
   ```

2. **Add renovate.json** for automated flake input updates (see Mic92's)
   ```json
   {
     "dependencyDashboard": true,
     "nix": { "enabled": true }
   }
   ```

3. **Consider sops-nix** for secrets if you want to share templates with community

### Medium Priority

4. **Export custom packages** for tools you wrap repeatedly (e.g., kubectl aliases, k3s helpers)
5. **Add extra substituters** to flake for faster builds:
   ```nix
   nixConfig.extra-substituters = [ "https://cache.cachix.org" ];
   ```

### Lower Priority

6. Explore **clan-core** if you add more machines with interdependent services
7. Add **multiple darwin hosts** if you expand macOS footprint

---

## 8. Summary

| Dimension | Your Strength | Mic92 Strength |
|-----------|--------------|----------------|
| Simplicity | ✅ Factory pattern is clear | Clan adds complexity |
| OCI/cloud | ✅ deploy-rs for OCI | Uses hetzner root servers |
| Custom packages | ❌ None | ✅ 25+ in-tree packages |
| Testing | Basic (alejandra) | Full check generation |
| Automation | None | renovate |
| Secrets | opnix (1Password) | sops-nix + age |

**Overall**: Your setup is lean, focused on OCI/k3s deployments with modern AI tooling. Mic92's is a mature, multi-machine monorepo with extensive custom tooling. Key improvements: add deadnix, add renovate, consider sops-nix for secrets portability.