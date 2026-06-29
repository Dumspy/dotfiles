{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "26.05";

  imports = [
    ../common/locale.nix
  ];

  # Boot options
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  zramSwap.enable = true;

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  # Modules shared across all OCI nodes
  myModules.system = {
    tailscale.enable = true;
    openssh = {
      enable = true;
      authorizedKeys = [config.var.publicKey];
    };
    shell.default = "zsh";
    deploy.enable = true;
    k3s = {
      enable = true;
      flannelIface = "enp0s6";
    };
  };

  # Networking
  networking.domain = "nixossn.nixosvcn.oraclevcn.com";
  networking.useDHCP = lib.mkDefault true;

  # User (credentials shared across the OCI cluster)
  users.users."${config.var.username}" = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = ["networkmanager" "wheel"];
    hashedPassword = "$y$j9T$8R.g9In3C6CZP1FVcRKoM.$5OcjxY6bfsihBD1mlRsirXvzIx0DZkBeQO74V5XCq96";
  };

  # Packages
  environment.systemPackages = with pkgs; [git htop curl k9s gcc gnumake];

  environment.variables = {
    KUBECONFIG = "$HOME/.kube/config";
  };

  # Firewall base ports (the server node appends its extra ports)
  networking.firewall.allowedTCPPorts = [22 41641 8472];
  networking.firewall.allowedUDPPorts = [41641 8472];
}
