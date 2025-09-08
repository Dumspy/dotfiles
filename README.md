TBD

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
    * `nix-shell -p git sops _1password-cli fzf`
    * `git clone https://github.com/Dumspy/dotfiles.git`
    * `cd ./dotfiles`
    * `dotfiles/nix/secrets/build.sh`
    * `dotfiles/rebuild.sh`

### WSL2 SSH Forwarding
npiperelay is needed for the SSH agent forwarding to work from the host system to the WSL instance.
Ensure that npiperelay is added to the PATH of the host Windows system.

https://github.com/jstarks/npiperelay
