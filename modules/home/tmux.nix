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
    catppuccin.tmux.enable = config.catppuccin.enable;
    catppuccin.tmux.extraConfig = ''
      set -g @catppuccin_window_status_style "rounded"
    '';

    programs.tmux = {
      enable = true;

      terminal = "screen-256color";
      baseIndex = 1;
      mouse = true;
      prefix = "C-Space";

      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
      ];

      extraConfig = ''
        # Catppuccin status bar (must be set after plugin loads)
        set -g status-left ""
        set -g status-right-length 100
        set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_session}"

        # Clipboard support for opencode in WSL
        set -g set-clipboard on
        set -g allow-passthrough all

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

        # Open new split panes in the same directory as the current pane
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # Sessionizer (keep, cht.sh removed)
        bind-key -r f run-shell "tmux neww tmux-sessionizer"
      '';
    };
  };
}
