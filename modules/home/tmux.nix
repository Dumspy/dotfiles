{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.tmux;
  portable = (config.myModules.home or {}).portable or false;
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
      '';

      programs.tmux = {
        enable = true;

        terminal = "screen-256color";
        baseIndex = 1;
        mouse = true;
        prefix = "C-Space";

        plugins = lib.mkIf (!portable) (with pkgs.tmuxPlugins; [
          sensible
          vim-tmux-navigator
        ]);
      };
    }

    (lib.mkIf portable {
      programs.tmux.extraConfig = ''
        # ============================================= #
        # TPM Plugin Manager (Portable Mode)          #
        # --------------------------------------------- #
        # Bootstrap script installs TPM via: git clone https://github.com/tmux-plugins/tpm
        # Press prefix+I in tmux to install plugins
        # ============================================= #

        set -g @plugin 'tmux-plugins/tpm'
        set -g @plugin 'tmux-plugins/tmux-sensible'
        set -g @plugin 'christoomey/vim-tmux-navigator'
        set -g @plugin 'catppuccin/tmux#v2.1.1'

        # Common tmux settings
        set -g status-left ""
        set -g status-right-length 100
        set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_session}"

        set -g set-clipboard on
        set -g allow-passthrough all
        set -ga terminal-overrides ",ghostty:Tc,*:RGB"
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        unbind C-b
        bind C-Space send-prefix

        # Reload config for portable mode
        bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded config"

        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind-key -r f run-shell "tmux neww tmux-sessionizer"

        # TPM loader (MUST be at end of config)
        run '~/.config/tmux/plugins/tpm/tpm'
      '';
    })

    (lib.mkIf (!portable) {
      programs.tmux.extraConfig = ''
        # ============================================= #
        # Load plugins with Home Manager (Nix Mode)   #
        # --------------------------------------------- #
        # Portable equivalent: set -g @plugin 'tmux-plugins/tmux-sensible'
        # ============================================= #

        set -g status-left ""
        set -g status-right-length 100
        set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_session}"

        set -g set-clipboard on
        set -g allow-passthrough all
        set -ga terminal-overrides ",ghostty:Tc,*:RGB"
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        unbind C-b
        bind C-Space send-prefix

        # Reload config reminder - Nix rebuild required
        bind r display-message "Config is managed by Nix. Run './rebuild.sh' to reload changes."

        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind-key -r f run-shell "tmux neww tmux-sessionizer"
      '';
    })
  ]);
}
