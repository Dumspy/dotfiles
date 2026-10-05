{config, ...}: {
  imports = [
    ../common/config.nix
    ../common/home.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = config.var.username;
  home.homeDirectory = config.var.homePrefix;

  myModules.home.shell.default = "fish";
  myModules.home.kubectl.enable = true;

  # Phase 1: enable herdr (alternative to tmux). tmux remains enabled via
  # hosts/common/home.nix during the transition. See docs/herdr-migration-plan.md.
  myModules.home.herdr.enable = true;

  # Enable zoxide smart directory navigation on this host first.
  # `cd` is replaced by zoxide (`cdi` for the interactive fzf picker);
  # `zd` is also available as a short explicit jump alias.
  myModules.home.zoxide.enable = true;

  programs.dot-agents.pi.keybindings = {
    "app.clipboard.pasteImage" = "alt+v";
  };
}
