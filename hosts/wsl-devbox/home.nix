{config, ...}: {
  imports = [
    ../common/config.nix
    ../common/home.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = config.var.username;
  home.homeDirectory = config.var.homePrefix;

  myModules.home.shell.default = "fish";
  myModules.home.kubectl.enable = true;
}
