{
  config,
  pkgs,
  me,
  ...
}: {
  imports = [
    ../home.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${me.username}";
  home.homeDirectory = "${me.homePrefix}";

  home.file = {
    ".config/zed/settings.json".source = ../../../zed/settings.json;
    ".config/zed/tasks.json".source = ../../../zed/tasks.json;
    ".config/ghostty".source = ../../../ghostty;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };

  programs.git = {
    extraConfig = {
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
  };
}
