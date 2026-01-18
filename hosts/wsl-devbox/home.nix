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
}
