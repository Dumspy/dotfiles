{config, ...}: {
  imports = [
    ../common/config.nix
    ../common/home.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = config.var.username;
  home.homeDirectory = config.var.homePrefix;

  # Homebrew CLI tools (casks with binaries: claude, code, dbeaver, zed, ...).
  # nix-darwin does not put the brew prefix on PATH for us.
  home.sessionPath = ["/opt/homebrew/bin"];

  myModules.home = {
    shell.default = "fish";
    ghostty.enable = true;
    herdr.enable = true;
    llama-cpp.enable = true;
    zoxide.enable = true;
    kubectl.enable = true;
    ssh = {
      enable = true;
      identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };
  };

  programs.git = {
    settings = {
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
  };
}
