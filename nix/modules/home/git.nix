{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Felix Berger";
        email = "felix.enok.berger@gmail.com";
      };

      github.user = "dumspy";
      core.excludesfile = "~/.gitignore_global";
      core.hooksPath = "~/git-hooks";
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
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHEA0GhkjkbuZGBnjtXSoQ9zpeXPCTTRYvfJX6RniI6";
    };
  };
}
