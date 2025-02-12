{ config, pkgs, ... }:

{
  imports = [
    ../home.nix
  ];
  
  home.file = {
    ".ssh_pipe".source = ../../../zsh/.ssh_pipe;
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  programs.git = {
    enable = true;
    
    userName = "Felix Berger";
    userEmail = "felix.enok.berger@gmail.com";

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHEA0GhkjkbuZGBnjtXSoQ9zpeXPCTTRYvfJX6RniI6";
    };

    extraConfig = {
      github.user = "dumspy";
      core.excludesfile = "~/.gitignore_global";
      core.hooksPath = "~/git-hooks";
      core.sshCommand = "ssh.exe";
      push.autoSetupRemote = true;
      gpg.format = "ssh";
      gpg.ssh.program = "/mnt/c/Users/felix/AppData/Local/1Password/app/8/op-ssh-sign-wsl";
      commit.gpgSign = true;
    };
  };
}
