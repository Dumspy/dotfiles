# Clan Commands Reference

Quick reference for `clan` CLI commands once clan-core is set up.

## Deployment

```bash
# Update a single machine
clan machines update <machine-name>

# Update all machines with a specific tag
clan machines update --tag <tag-name>

# Update all machines
clan machines update

# Update multiple specific machines
clan machines update machine1 machine2 machine3

# Build locally but don't deploy (dry-run)
clan machines update --build-only <machine-name>
```

## Tags (once configured in inventory)

Assuming these tags are defined in `machines/inventory.nix`:

```bash
# Update all OCI nodes
clan machines update --tag oci

# Update all servers (non-workstations)
clan machines update --tag servers

# Update all workstations
clan machines update --tag workstations
```

## SSH

```bash
# SSH into a machine using clan's configured targetHost
clan machines ssh <machine-name>

# SSH and forward agent
clan machines ssh --forward-agent <machine-name>
```

## Info & Inspection

```bash
# List all machines in the clan
clan machines list

# Show machine details
clan machines show <machine-name>

# Show flake output for a machine
clan flakes show <machine-name>
```

## Secrets (if using clan vars instead of opnix)

```bash
# Set a secret var for a machine
clan vars set <machine-name> <var-name>

# Get a secret var
clan vars get <machine-name> <var-name>

# List vars for a machine
clan vars list <machine-name>
```

## Backup (if using clan backup services)

```bash
# Trigger backup for a machine
clan backups create <machine-name>

# List backup status
clan backups list <machine-name>
```

## VM Testing

```bash
# Build and run a machine as a local VM
clan vms run <machine-name>
```

## Initial Setup / Installation

```bash
# Install NixOS on a new machine via SSH
clan machines install <machine-name> --target-host user@host

# Flash an SD card for a machine
clan flash <machine-name> /dev/sdX
```

## Comparison: deploy-rs vs clan

| Task | deploy-rs | clan-core |
|------|-----------|-----------|
| Deploy one node | `deploy .#oci-node-1` | `clan machines update oci-node-1` |
| Deploy all OCI | Loop in script | `clan machines update --tag oci` |
| SSH into node | `ssh deploy@100.99.30.112` | `clan machines ssh oci-node-1` |
| Add new node | Edit `flake.nix` + `deploy.nix` | Add to `machines/inventory.nix` |

## Notes

- Clan uses the `deploy.targetHost` from `machines/inventory.nix` for SSH connections
- Remote build can be configured per-machine with `deploy.buildHost`
- The `--skip-checks` equivalent in clan depends on your flake checks setup
