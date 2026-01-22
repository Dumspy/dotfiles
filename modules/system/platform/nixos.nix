{
  config,
  pkgs,
  ...
}: {
  config = {
    users.defaultUserShell =
      if config.myModules.system.shell.default == "fish"
      then pkgs.fish
      else pkgs.zsh;

    environment.localBinInPath = true;
  };
}
