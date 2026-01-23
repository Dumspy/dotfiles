{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.home.git;
in {
  options.myModules.home.git = {
    enable = lib.mkEnableOption "git with signing and aliases";

    userName = lib.mkOption {
      type = lib.types.str;
      default = "Felix Berger";
      description = "Git user name";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "felix.enok.berger@gmail.com";
      description = "Git user email";
    };

    signingKey = lib.mkOption {
      type = lib.types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHEA0GhkjkbuZGBnjtXSoQ9zpeXPCTTRYvfJX6RniI6";
      description = "SSH signing key";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;

      ignores = [
        ".DS_Store"
      ];

      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };

        github.user = "dumspy";
        push.autoSetupRemote = true;
        gpg.format = "ssh";
        commit.gpgSign = true;
        core.editor = "nvim";

        aliases = {
          dlog = "-c diff.external=difft log --ext-diff";
          dshow = "-c diff.external=difft show --ext-diff";
          ddiff = "-c diff.external=difft diff";
        };
      };
      signing = {
        key = cfg.signingKey;
      };
    };
  };
}
