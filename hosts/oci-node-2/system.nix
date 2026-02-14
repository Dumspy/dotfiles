{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "24.11";
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/oci-keepalive.nix
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

  # Modules
  myModules.system = {
    onepassword.enable = true;
    tailscale.enable = true;
    oci-keepalive = {
      enable = true;
      activeHours = "06-22";
      minLoad = 5;
      maxLoad = 30;
    };
    openssh = {
      enable = true;
      authorizedKeys = [config.var.publicKey];
    };
    shell.default = "zsh";
    deploy.enable = true;
    k3s = {
      enable = true;
      role = "agent";
      serverAddr = "https://10.0.1.215:6443";
      nodeIp = "10.0.1.68";
      flannelIface = "enp0s6";
      extraFlags = ["--node-external-ip=10.0.1.68"];
    };
  };

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  services.onepassword-secrets.secrets = {
    k3sToken = {
      reference = "op://OCI-Secrets/cluster-token/credential";
      owner = "root";
      group = "root";
      services = ["k3s"];
    };
  };

  # Networking
  networking.hostName = "oci-node-2";
  networking.domain = "nixossn.nixosvcn.oraclevcn.com";
  networking.useDHCP = lib.mkDefault true;

  # Proxy configuration using oci-node-3
  networking.proxy.default = "http://10.0.1.215:8888";
  networking.proxy.noProxy = "localhost,127.0.0.1,10.0.1.0/24";

  systemd.globalEnvironment = {
    HTTP_PROXY = "http://10.0.1.215:8888";
    HTTPS_PROXY = "http://10.0.1.215:8888";
    NO_PROXY = "localhost,127.0.0.1,10.0.1.0/24";
  };

  # Time zone
  time.timeZone = "Europe/Copenhagen";

  # Locale
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # User
  users.users.nixos = {
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

  services.k3s.tokenFile = config.services.onepassword-secrets.secretPaths.k3sToken;

  # Firewall
  networking.firewall.allowedTCPPorts = [22 41641 8472];
  networking.firewall.allowedUDPPorts = [41641 8472];
}
