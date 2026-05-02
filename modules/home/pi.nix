{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.myModules.home.pi;
  llm-agents-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  jsonFormat = pkgs.formats.json {};
in {
  options.myModules.home.pi = {
    enable = lib.mkEnableOption "pi coding agent";

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = {};
      description = ''
        Configuration written to {file}`~/.pi/agent/settings.json`.
        See <https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/settings.md>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [llm-agents-pkgs.pi];

    home.file.".pi/agent/settings.json" = lib.mkIf (cfg.settings != {}) {
      source = jsonFormat.generate "pi-settings.json" cfg.settings;
    };
  };
}
