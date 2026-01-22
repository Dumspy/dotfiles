{config, ...}: {
  imports = [
    ../config.nix
    ../home.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = config.var.username;
  home.homeDirectory = config.var.homePrefix;

  myModules.home = {
    shell.default = "fish";
    ghostty.enable = true;
    ssh = {
      enable = true;
      identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };
  };

  programs.git = {
    extraConfig = {
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
  };
}
