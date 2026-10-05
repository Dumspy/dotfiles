{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.pi;
  jsonFormat = pkgs.formats.json {};
  settingsJson = builtins.toJSON cfg.settings;
in {
  options.myModules.home.pi = {
    enable = lib.mkEnableOption "pi coding agent";

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = {};
      description = ''
        Initial configuration for {file}`~/.pi/agent/settings.json`.
        Written once if the file does not exist; Pi and other tools
        may modify the file afterwards.
        See <https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/settings.md>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.auxera.pi];

    # settings.json is mutable state — Pi edits it at runtime and dot-agents
    # merges packages into it via activation script. We write a regular file
    # (not a store symlink) so those modifications actually persist.
    home.activation.piSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      SETTINGS="${config.home.homeDirectory}/.pi/agent/settings.json"
      mkdir -p "$(dirname "$SETTINGS")"

      if [ -L "$SETTINGS" ]; then
        # Convert an old store symlink to a real file so Pi can edit it
        cp -L "$SETTINGS" "$SETTINGS.tmp"
        mv "$SETTINGS.tmp" "$SETTINGS"
      fi

      if [ ! -f "$SETTINGS" ]; then
        echo '${settingsJson}' > "$SETTINGS"
        chmod 644 "$SETTINGS"
      fi
    '';
  };
}
