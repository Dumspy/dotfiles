{
  pkgs,
  lib,
  config,
  ...
}: {
  packages = with pkgs; [
    alejandra
    deadnix
  ];

  # Pre-commit hooks (replaces git-hooks in the main flake).
  # The generated `.pre-commit-config.yaml` is managed by devenv in `.devenv/`.
  git-hooks.hooks.alejandra = {
    enable = true;

    # Exclude generated / vendored directories so pre-commit doesn't even
    # invoke the hook on them. Patterns are pre-commit regex (matched against
    # repo-relative paths). Note: there's no global excludes in this version
    # of git-hooks.nix, so new hooks need this same attribute.
    excludes = [
      "^\\.devenv/"
      "^\\.direnv/"
      "^result$"
    ];
  };

  # Runs in CI via `devenv test`.
  enterTest = ''
    pre-commit run --all-files
  '';
}
