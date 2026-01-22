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

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;

      terminal = "screen-256color";
      baseIndex = 1;
      mouse = true;
      prefix = "C-Space";

      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavor 'macchiato'
            set -g @catppuccin_window_status_style "rounded"
          '';
        }
      ];

      extraConfig = ''
        # Terminal colors and 256 color support
        set -ga terminal-overrides ",ghostty:Tc,*:RGB"

        # Window numbering
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # Prefix keybindings
        unbind C-b
        bind C-Space send-prefix

        # Reload config reminder - Nix rebuild required
        bind r display-message "Config is managed by Nix. Run './rebuild.sh' to reload changes."

        # Status bar configuration
        set -g status-right-length 100
        set -g status-left-length 100
        set -g status-left ""
        set -g status-right "#{E:@catppuccin_status_application}"
        set -ag status-right "#{E:@catppuccin_status_session}"

        # Open new split panes in the same directory as the current pane
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # Sessionizer (keep, cht.sh removed)
        bind-key -r f run-shell "tmux neww tmux-sessionizer"
      '';
    };
  };
}
