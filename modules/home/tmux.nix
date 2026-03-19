{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.tmux;
in {
  options.myModules.home.tmux = {
    enable = lib.mkEnableOption "tmux with vim navigation";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      catppuccin.tmux.enable = config.catppuccin.enable;
      catppuccin.tmux.extraConfig = ''
        set -g @catppuccin_flavor 'macchiato'
        set -g @catppuccin_window_status_style "rounded"
        set -g @catppuccin_window_status_enable "yes"
        set -g @catppuccin_window_status_icon_enable "yes"

        set -g @catppuccin_icon_window_zoom "null"
        set -g @catppuccin_icon_window_last "null"
        set -g @catppuccin_icon_window_current "null"
        set -g @catppuccin_icon_window_mark "null"
        set -g @catppuccin_icon_window_silent "null"
        set -g @catppuccin_icon_window_activity "null"
        set -g @catppuccin_icon_window_bell "null"

        set -g @catppuccin_window_default_background "surface0"
        set -g @catppuccin_window_default_color "base"
        set -g @catppuccin_window_default_fill "all"
        set -g @catppuccin_window_default_text " #T"

        set -g @catppuccin_window_current_background "surface1"
        set -g @catppuccin_window_current_color "mauve"
        set -g @catppuccin_window_current_fill "all"
        set -g @catppuccin_window_current_text " #T"
      '';

      programs.tmux = {
        enable = true;
        terminal = "screen-256color";
        escapeTime = 0;
        historyLimit = 50000;
        focusEvents = true;
        aggressiveResize = true;
        baseIndex = 1;
        mouse = true;
        prefix = "C-Space";
        sensibleOnTop = false;

        extraConfig = ''
          set -g display-time 4000
          set -g status-interval 5
          set -s extended-keys on
          set -g extended-keys-format csi-u
          set -as terminal-features 'xterm*:extkeys'
          set -as terminal-features 'xterm-ghostty:extkeys'

          # True color support
          set -ga terminal-overrides ",*:Tc"
          set -ga terminal-overrides ",ghostty:Tc"

          set -g status-position top
          set -g renumber-windows on

          # Catppuccin status bar (must be set after plugin loads)
          set -g status-left ""
          set -g status-right-length 100
          set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_session}"

          bind x kill-pane
          bind c new-window -c "#{pane_current_path}"
          bind-key -r f run-shell "tmux neww tmux-sessionizer"
        '';
        plugins = with pkgs.tmuxPlugins; [
          sensible
          vim-tmux-navigator
          (pkgs.tmuxPlugins.resurrect.overrideAttrs {
            pluginExtraConfig = ''
              set -g @resurrect-strategy-vim 'session'
              set -g @resurrect-strategy-nvim 'session'
              set -g @resurrect-capture-pane-contents 'on'
            '';
          })
          (pkgs.tmuxPlugins.continuum.overrideAttrs {
            pluginExtraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-boot 'off'
              set -g @continuum-save-interval '10'
            '';
          })
        ];
      };
    }
  ]);
}
