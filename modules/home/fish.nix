{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.home.fish;
  shellCfg = config.myModules.home.shell;
  portable = config.myModules.home.portable or false;
in {
  options.myModules.home.fish = {
    enable = lib.mkEnableOption "fish shell with plugins and completions";
  };

  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit =
        ''
          set fish_greeting
        ''
        + lib.optionalString portable ''
          # Source local overrides (not managed by dotfiles)
          if test -f ~/.config/fish/config.local.fish
            source ~/.config/fish/config.local.fish
          end
        '';

      plugins = lib.mkIf (!portable) [
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];

      functions = {
        fish_user_key_bindings = ''
          bind \cf "commandline -C 0; tmux-sessionizer"
        '';
      };

      shellAliases = shellCfg.aliases;
      shellAbbrs = {
        ga = "git add";
        gc = "git commit";
        gco = "git checkout";
        gcp = "git cherry-pick";
        gdiff = "git diff";
        gp = "git push";
        gs = "git status";
        gt = "git tag";
      };
    };
  };
}
