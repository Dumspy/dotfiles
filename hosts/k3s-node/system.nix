{
  config,
  pkgs,
  ...
}: {
  system.stateVersion = "26.05";

  imports = [
    ./hardware-configuration.nix
  ];

  myModules.system = {
    k3s = {
      enable = true;
      extraFlags = ["--tls-san=100.109.48.72"];
    };
    tailscale.enable = true;
    openssh = {
      enable = true;
      tailscaleOnly = true;
      authorizedKeys = [config.var.publicKey];
    };
    deploy.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "k3s-node";

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  users.groups = {
    certs = {
      gid = 1001;
    };
  };

  users.users.nixos = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = [
      "networkmanager"
      "wheel"
      "certs"
    ];
  };

  environment.systemPackages = [
    pkgs.gcc
    pkgs.gnumake
    pkgs.k9s
  ];

  environment.variables = {
    KUBECONFIG = "$HOME/.kube/config";
  };

  # Prometheus node_exporter. Left on all interfaces, along with the k3s
  # module's 6443/8472. This node does not set --node-ip, so k3s uses the
  # default-route NIC (enp6s18 when hardware-configuration.nix was generated)
  # and only adds the Tailscale IP as a TLS SAN. In-cluster hostPort scrapes
  # also arrive on the CNI interface, not tailscale0.
  networking.firewall.allowedTCPPorts = [9100];
}
