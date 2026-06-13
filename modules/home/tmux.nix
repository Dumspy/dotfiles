{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.tmux;

  # Catppuccin Macchiato palette (https://catppuccin.com/palette)
  colors = {
    base = "#24273a";
    mantle = "#1e2030";
    crust = "#181926";
    surface0 = "#363a4f";
    text = "#cad3f5";
    overlay0 = "#6e738d";
    overlay1 = "#8087a2";
    mauve = "#c6a0f6";
    red = "#ed8796";
    green = "#a6da95";
  };
in {
  options.myModules.home.tmux = {
    enable = lib.mkEnableOption "tmux with vim navigation";
  };

  config = lib.mkIf cfg.enable {
    # hosts/common/home.nix sets catppuccin.enable, which auto-enables
    # catppuccin.tmux. Disable it here so the manual status bar config wins.
    catppuccin.tmux.enable = false;

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
        set -g status-interval 1
        set -s extended-keys on
        set -g extended-keys-format csi-u
        set -as terminal-features 'xterm*:extkeys'
        set -as terminal-features 'xterm-ghostty:extkeys'

        # True color support
        set -ga terminal-overrides ",*:Tc"
        set -ga terminal-overrides ",ghostty:Tc"

        set -g status-position top
        set -g renumber-windows on

        # Status bar (Catppuccin Macchiato)
        set -g status-justify left
        set -g status-style "bg=${colors.mantle},fg=${colors.text}"

        # Left: session name (mauve) + dim separator
        set -g status-left "#[fg=${colors.mauve},bold] #S #[fg=${colors.overlay1}]│ "
        set -g status-left-length 20

        # Right: colored circle shows prefix state (red=on, green=off), clock in text color
        set -g status-right "#{?client_prefix,#[fg=${colors.red}],#[fg=${colors.green}]}● #[fg=${colors.text}]%-I:%M %p "
        set -g status-right-length 50

        # Windows: inline list, active window in mauve
        setw -g window-status-format "#[fg=${colors.overlay1}] #I #W "
        setw -g window-status-current-format "#[fg=${colors.mauve},bold] #I #W "
        setw -g window-status-separator ""

        # Pane borders
        set -g pane-border-lines simple
        set -g pane-border-style "fg=${colors.overlay0}"
        set -g pane-active-border-style "fg=${colors.mauve}"

        # Message / mode styles
        set -g message-style "bg=${colors.surface0},fg=${colors.text}"
        set -g message-command-style "bg=${colors.surface0},fg=${colors.text}"
        setw -g mode-style "bg=${colors.surface0},fg=${colors.text},bold"

        # Clock
        setw -g clock-mode-colour "${colors.mauve}"

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
  };
}
