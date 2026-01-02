## Secrets Management

Secrets are managed using [opnix](https://github.com/brizzbuzz/opnix), a built-in 1Password integration for Nix. This provides secure, declarative secrets management without committing sensitive data to the repository.

### Setup

1. **Install 1Password CLI**: The `op` CLI tool must be available on your system
2. **Create a token file**: Store your 1Password service account token at `/etc/opnix-token`
   ```bash
   echo "your-service-account-token" | sudo tee /etc/opnix-token
   sudo chmod 600 /etc/opnix-token
   ```
3. **Configure secrets**: Add secrets in `nix/modules/system/onepassword.nix`:
   ```nix
   services.onepassword-secrets = {
     enable = true;
     tokenFile = "/etc/opnix-token";
     secrets = {
       mySecret = {
         reference = "op://VaultName/ItemName/field";
       };
     };
   };
   ```

### How It Works

- Secrets are referenced using 1Password URI format: `op://VaultName/ItemName/field`
- The opnix service runs at boot and fetches secrets from 1Password
- Secrets are made available to the system without being stored in the Nix store
- The token file (`/etc/opnix-token`) is never committed to version control

### SSH Agent Integration

For WSL systems, 1Password SSH agent is integrated via `1password-agent.nix`:
- SSH agent is forwarded from Windows host to WSL using npiperelay
- SSH_AUTH_SOCK is automatically configured system-wide
- Git operations can use SSH keys stored in 1Password

### WSL Install Steps
* Enable WSL if you haven't done already:
   * `wsl --install --no-distribution`
* Download nixos.wsl from the [latest release](https://github.com/nix-community/NixOS-WSL/releases/tag/2505.7.0).
* Double-click the file you just downloaded (requires WSL >= 2.4.4)
* You can now run NixOS:
   * `wsl -d NixOS`
* The following commands:
    * `cd`
    * `export NIXPKGS_ALLOW_UNFREE=1`
    * `nix-shell -p git fzf`
    * `git clone https://github.com/Dumspy/dotfiles.git`
    * `cd ./dotfiles`
    * `dotfiles/rebuild.sh`

### WSL2 SSH Forwarding
npiperelay is needed for the SSH agent forwarding to work from the host system to the WSL instance.
Ensure that npiperelay is added to the PATH of the host Windows system.

https://github.com/jstarks/npiperelay
