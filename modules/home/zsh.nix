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
      enableCompletion = true;
      autosuggestion.enable = true;
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
        ''
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' menu no
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

          bindkey -s ^f "tmux-sessionizer\n"
        ''
        (lib.mkIf portable ''
          # Source local overrides (not managed by dotfiles)
          [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
        '')
      ];
    };
  };
}
