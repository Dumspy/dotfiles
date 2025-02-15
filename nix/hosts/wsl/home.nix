{
  config,
  pkgs,
  me,
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
  home.username = "${me.username}";
  home.homeDirectory = "${me.homePrefix}";

  programs.git = {
    extraConfig = {
      gpg.ssh.program = "/mnt/c/Users/felix/AppData/Local/1Password/app/8/op-ssh-sign-wsl";
      core.sshCommand = "ssh.exe";
    };
  };
}
