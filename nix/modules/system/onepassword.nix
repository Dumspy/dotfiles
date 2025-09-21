{
  config,
  pkgs,
  lib,
  ...
}: {
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";

    secrets = {
      pocPassword = {
        reference = "op://NixSecrets/POC/password";
      };
    };
  };
}
