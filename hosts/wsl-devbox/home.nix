{...}: {
  myModules.home.shell.default = "fish";
  myModules.home.kubectl.enable = true;

  # Enable herdr (alternative to tmux). tmux remains enabled via
  # hosts/common/home.nix during the transition.
  myModules.home.herdr.enable = true;

  # Smart directory navigation (`cd` replaced by zoxide, `cdi` for fzf picker).
  myModules.home.zoxide.enable = true;

  programs.dot-agents.pi.keybindings = {
    "app.clipboard.pasteImage" = "alt+v";
  };
}
