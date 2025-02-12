{ config, pkgs, ... }:

{
  imports = [
    ../home.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "felix.berger";
  home.homeDirectory = "/Users/felix.berger";

  home.file = {
    ".config/zed/settings.json".source = ../../../zed/settings.json;
    ".config/zed/tasks.json".source = ../../../zed/tasks.json;
    ".config/ghostty".source = ../../../ghostty;
    ".gitconfig".source = ../../../git/.gitconfig;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };
}
