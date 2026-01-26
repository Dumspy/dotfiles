{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.zsh;
  shellCfg = config.myModules.home.shell;
  portable = config.myModules.home.portable or false;
in {
  options.myModules.home.zsh = {
    enable = lib.mkEnableOption "zsh shell with fzf-tab and completions";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = lib.mkIf (!portable) true;
      autosuggestion.enable = lib.mkIf (!portable) true;
      shellAliases = shellCfg.aliases;

      plugins = lib.mkIf (!portable) [
        {
          name = "fzf-tab";
          src = pkgs.fetchFromGitHub {
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "v1.1.2";
            sha256 = "Qv8zAiMtrr67CbLRrFjGaPzFZcOiMVEFLg1Z+N6VMhg=";
          };
        }
      ];

      initContent = lib.mkMerge [
        (lib.mkIf (!portable) ''
          # ============================================= #
          # Load plugins with Home Manager (Nix Mode)    #
          # --------------------------------------------- #
          # Portable equivalent: ~/.local/share/zsh/plugins/
          # ============================================= #

          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' menu no
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

          bindkey -s ^f "tmux-sessionizer\n"
        '')
        (lib.mkIf portable ''
          # ============================================= #
          # Zsh Plugins (Portable Mode)                 #
          # --------------------------------------------- #
          # Bootstrap script installs these via GitHub clone:
          # - zsh-autosuggestions
          # - fzf-tab (optional - uncomment to enable)
          # Nix equivalents: programs.zsh.plugins, programs.zsh.autosuggestion
          # ============================================= #

          # zsh-autosuggestions (installed by bootstrap)
          ZSH_AUTOSUGGESTIONS_DIR="$HOME/.local/share/zsh/plugins/zsh-autosuggestions"
          if [[ -f "$ZSH_AUTOSUGGESTIONS_DIR/zsh-autosuggestions.zsh" ]]; then
            source "$ZSH_AUTOSUGGESTIONS_DIR/zsh-autosuggestions.zsh"
          fi

          # fzf-tab (optional - not installed by default)
          # Uncomment following lines to enable:
          # FZF_TAB_DIR="$HOME/.local/share/zsh/plugins/fzf-tab"
          # if [[ -f "$FZF_TAB_DIR/fzf-tab.zsh" ]]; then
          #   source "$FZF_TAB_DIR/fzf-tab.zsh"
          # fi

          # Common settings
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' menu no
          bindkey -s ^f "tmux-sessionizer\n"

          # Source local overrides (not managed by dotfiles)
          [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
        '')
      ];
    };
  };
}
