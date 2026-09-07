{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.herdr;

  # Use the integration bundled in the exact Herdr source selected by Auxera.
  # Updating pkgs.auxera.herdr therefore updates the deployed integration too.
  herdrPiIntegration = "${pkgs.auxera.herdr.src}/src/integration/assets/pi/herdr-agent-state.ts";

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
    # `extraExtensions` is deployed by dot-agents' Home Manager module. This
    # replaces `herdr integration install pi`: Nix writes the integration bundled
    # with the pinned Herdr source into Pi's global extension directory.
    programs.dot-agents.pi.extraExtensions."herdr-agent-state.ts" = herdrPiIntegration;

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
              # herdr renders non-active auto-named tabs as `overlay0` + DIM on
              # `surface0` (tabs.rs:333). With the Macchiato overlay0 (#6e738d)
              # the DIM'd text collapses against surface0 (#363a4f) and is
              # unreadable. Lift overlay0 to subtext0 (#a5adcb) so the inactive
              # tab text stays light-on-dark like our tmux status bar. Aligns
              # with overlay1 (#8087a2) — overlay1 is already used by named
              # inactive tabs without DIM, so the two stay visually consistent.
              overlay0 = macchiato.subtext0;
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

          # Preserve tmux muscle memory. Herdr's workspace/tab model is closest
          # to tmux's session/window model, respectively. Keys with no Herdr
          # equivalent (layouts, pane numbers, paste buffers, and the command
          # prompt) deliberately retain no binding rather than approximating a
          # different action.
          keys = {
            prefix = "ctrl+space";

            # Session/workspace navigation. `goto` is Herdr's navigator, so it
            # replaces our tmux-sessionizer binding as well as tmux's `prefix+w`.
            workspace_picker = "prefix+s";
            goto = ["prefix+f" "prefix+w"];
            rename_workspace = "prefix+$";
            previous_workspace = "prefix+(";
            next_workspace = "prefix+)";
            settings = "prefix+shift+s";
            detach = "prefix+d";
            reload_config = "prefix+r";
            resize_mode = "prefix+shift+r";
            open_notification_target = "prefix+shift+o";

            # Window/tab actions. `new_cwd = "follow"` below gives prefix+c
            # the same current-directory behavior as our tmux override.
            new_tab = "prefix+c";
            rename_tab = "prefix+comma";
            previous_tab = "prefix+p";
            next_tab = "prefix+n";
            switch_tab = "prefix+1..9";
            close_tab = "prefix+&";

            # Pane actions. Keep Herdr's vim-style movement too, while adding
            # tmux's arrow keys and native % / " split keys.
            copy_mode = "prefix+[";
            focus_pane_left = ["prefix+h" "prefix+left"];
            focus_pane_down = ["prefix+j" "prefix+down"];
            focus_pane_up = ["prefix+k" "prefix+up"];
            focus_pane_right = ["prefix+l" "prefix+right"];
            cycle_pane_next = ["prefix+tab" "prefix+o"];
            last_pane = "prefix+;";
            split_vertical = "prefix+%";
            split_horizontal = "prefix+\"";
            close_pane = "prefix+x";
            zoom = "prefix+z";
          };

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
