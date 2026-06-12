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
    traefik.enable = true;
    tailscale.enable = true;
    openssh = {
      enable = true;
      authorizedKeys = [config.var.publicKey];
    };
    deploy.enable = true;
    supermemory = {
      enable = true;
      openFirewall = true;
      environment = {
        OPENAI_BASE_URL = "https://opencode.ai/zen/go/v1/chat/completions";
        OPENAI_MODEL = "deepseek-v4-flash";
      };
      environmentFile = config.services.onepassword-secrets.secretPaths.supermemoryEnv;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "master-node";

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

  users.users.nixos = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  environment.systemPackages = [
    pkgs.gcc
    pkgs.gnumake
  ];

  myModules.system.onepassword = {
    enable = true;
    secrets = {
      supermemoryEnv = {
        reference = "op://NixSecrets/SuperMemory/env";
        owner = "supermemory";
        group = "supermemory";
        services = ["supermemory"];
      };
    };
  };
}
