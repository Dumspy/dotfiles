# Time-limited git SSH auth + commit signing for unattended agents
# (packages/git-auth). Repos matching `gitdirs` use a session key loaded with
# `git-auth login`; everything else keeps the default (1Password) setup.
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.system.git-auth;

  pkg = pkgs.callPackage ../../packages/git-auth/package.nix {
    inherit (cfg) opReference opCommand lifetime;
  };

  includeFile = "${pkg}/share/git-auth/git-auth.inc";

  # The 1Password signing setup lives in the Home Manager git config, which
  # git reads after /etc/gitconfig. Where Home Manager exists the includes
  # must go there, after it, to win; elsewhere /etc/gitconfig is enough.
  hasHomeManager = options ? home-manager;
in {
  options.myModules.system.git-auth = {
    enable = lib.mkEnableOption "time-limited git SSH auth/signing session for unattended agents";

    opReference = lib.mkOption {
      type = lib.types.str;
      default = "op://Private/Agent Git Key/private key?ssh-format=openssh";
      description = "1Password reference to the dedicated agent SSH private key";
    };

    opCommand = lib.mkOption {
      type = lib.types.str;
      # Only macOS has 1Password desktop integration for the CLI. Elsewhere
      # (WSL, servers) log in from the Mac with `git-auth login --remote`, or
      # point this at op.exe on WSL.
      default =
        if pkgs.stdenv.hostPlatform.isDarwin
        then lib.getExe pkgs._1password-cli
        else "op";
      defaultText = lib.literalExpression ''if isDarwin then lib.getExe pkgs._1password-cli else "op"'';
      description = "1Password CLI used by `git-auth login`";
    };

    lifetime = lib.mkOption {
      type = lib.types.str;
      default = "24h";
      description = "Default session lifetime (s/m/h/d suffix)";
    };

    gitdirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      # Linked worktrees resolve gitdir to <main>/.git/worktrees/<name>, so
      # match T3 worktrees by name rather than by checkout path.
      default = ["**/.git/worktrees/t3-*"];
      description = "git `includeIf gitdir:` patterns that use the session key";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {environment.systemPackages = [pkg];}

    (lib.optionalAttrs hasHomeManager {
      home-manager.sharedModules = [
        {
          programs.git.includes =
            map (p: {
              condition = "gitdir:${p}";
              path = includeFile;
            })
            cfg.gitdirs;
        }
      ];
    })

    (lib.optionalAttrs (!hasHomeManager) {
      programs.git = {
        enable = true;
        config = map (p: {includeIf."gitdir:${p}".path = includeFile;}) cfg.gitdirs;
      };
    })
  ]);
}
