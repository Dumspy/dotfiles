{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ../home.nix
  ];

  home.file = {
    ".ssh_pipe".source = ../../../zsh/.ssh_pipe;
  };

  programs.zsh = {
    initExtra = ''
      source ~/.ssh_pipe
    '';
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  programs.git = {
    extraConfig = {
      gpg.ssh.program = "/mnt/c/Users/felix/AppData/Local/1Password/app/8/op-ssh-sign-wsl";
    };
  };
}
