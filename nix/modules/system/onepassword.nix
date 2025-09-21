{
  config,
  pkgs,
  lib,
  ...
}: {
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
  };
}
