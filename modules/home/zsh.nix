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

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
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
            # Portable modules loader                       #
            # --------------------------------------------- #
            # In portable mode, module-specific zsh setup is
            # split into files under ~/.config/zsh/modules.
            # This keeps ~/.zshrc focused on bootstrapping.
            # ============================================= #

            if [[ -d "$HOME/.config/zsh/modules" ]]; then
              for module in "$HOME"/.config/zsh/modules/*.zsh(N); do
                source "$module"
              done
            fi

            # Source local overrides (not managed by dotfiles)
            [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
          '')
        ];
      };
    })

    (lib.mkIf (cfg.enable && portable) {
      home.file = lib.mkMerge [
        {
          ".config/zsh/modules/00-portable-core.zsh".text = ''
            # Core portable zsh defaults
            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
            zstyle ':completion:*' menu no
            bindkey -s ^f "tmux-sessionizer\n"
          '';

          ".config/zsh/modules/10-zsh-plugins.zsh".text = ''
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
          '';
        }
        (lib.mkIf config.myModules.home.starship.enable {
          ".config/zsh/modules/20-starship.zsh".text = ''
            if command -v starship >/dev/null 2>&1; then
              eval "$(starship init zsh)"
            fi
          '';
        })
        (lib.mkIf config.myModules.home.fzf.enable {
          ".config/zsh/modules/30-fzf.zsh".text = ''
            if command -v fzf >/dev/null 2>&1; then
              source <(fzf --zsh)
            fi
          '';
        })
        (lib.mkIf config.myModules.home.direnv.enable {
          ".config/zsh/modules/40-direnv.zsh".text = ''
            if command -v direnv >/dev/null 2>&1; then
              eval "$(direnv hook zsh)"
            fi
          '';
        })
      ];
    })
  ];
}
