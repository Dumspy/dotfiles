{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    environment.variables = {
      PATH = "$HOME/.local/bin:$PATH";
    };
  };
}
