{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.herdr;

  # Catppuccin Macchiato palette (https://catppuccin.com/palette).
  # herdr's built-in `catppuccin` theme is Mocha, so we override every theme
  # token to Macchiato via [theme.custom] (migration plan §5). Mirrors the same
  # palette already pinned in modules/home/tmux.nix.
  macchiato = {
    base = "#24273a";
    mantle = "#1e2030";
    crust = "#181926";
    surface0 = "#363a4f";
    surface1 = "#494d64";
    overlay0 = "#6e738d";
    overlay1 = "#8087a2";
    text = "#cad3f5";
    subtext0 = "#a5adcb";
    mauve = "#c6a0f6";
    green = "#a6da95";
    yellow = "#eed49f";
    red = "#ed8796";
    blue = "#8aadf4";
    teal = "#8bd5ca";
    peach = "#f5a97f";
  };
in {
  options.myModules.home.herdr = {
    enable = lib.mkEnableOption "herdr terminal workspace manager";

    settings = lib.mkOption {
      inherit (pkgs.formats.toml {}) type;
      default = {};
      description = ''
        herdr config written to {file}`$XDG_CONFIG_HOME/herdr/config.toml`
        via the upstream Home Manager `programs.herdr` module.
        See <https://herdr.dev/docs/config-reference/> for the full key list;
        unset keys fall back to herdr defaults.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.herdr = {
      enable = true;
      # Auxera's from-source herdr (pkgs/herdr in Auxera/nixpkgs). Wins over the
      # nixpkgs default via the auxera overlay applied in lib/default.nix.
      package = pkgs.auxera.herdr;

      # Curated defaults. Per-host `myModules.home.herdr.settings` merges over
      # these (lib.recursiveUpdate), so hosts only need to override specifics.
      settings =
        lib.recursiveUpdate {
          onboarding = false;

          # Base theme stays `catppuccin` (Mocha); [theme.custom] overrides every
          # token herdr exposes onto Macchiato so the UI matches our dotfiles.
          theme = {
            name = "catppuccin";
            custom = {
              accent = macchiato.mauve; # our catppuccin accent is mauve
              panel_bg = macchiato.mantle;
              surface0 = macchiato.surface0;
              surface1 = macchiato.surface1;
              surface_dim = macchiato.crust;
              overlay0 = macchiato.overlay0;
              overlay1 = macchiato.overlay1;
              text = macchiato.text;
              subtext0 = macchiato.subtext0;
              mauve = macchiato.mauve;
              green = macchiato.green;
              yellow = macchiato.yellow;
              red = macchiato.red;
              blue = macchiato.blue;
              teal = macchiato.teal;
              peach = macchiato.peach;
            };
          };

          keys.prefix = "ctrl+space"; # mirror our tmux prefix (decision §11.3)

          terminal = {
            shell_mode = "auto";
            new_cwd = "follow";
          };

          ui = {
            confirm_close = true;
            pane_borders = true;
            mouse_capture = true;
            # Override herdr's default `cyan` accent with our mauve so highlights,
            # borders, and navigation UI match the catppuccin accent we use
            # everywhere else (hosts/common/home.nix sets catppuccin.accent).
            accent = macchiato.mauve;
            toast.delivery = "herdr";
            sound.enabled = true;
          };

          remote.manage_ssh_config = true;

          session.resume_agents_on_restore = true;

          # Share wt's worktree store instead of herdr's default ~/.herdr/worktrees
          # so herdr-native and `wt`-created worktrees live under one root. Confirm
          # checkout-layout compatibility before relying on it (migration plan §8).
          worktrees.directory = "~/.wt-worktrees";
        }
        cfg.settings;
    };
  };
}
