{
  pkgs,
  lib,
  ...
}: {
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";

    # Placeholder image (required by stylix)
    image = lib.mkDefault (
      pkgs.runCommand "placeholder.png" {} ''
        ${pkgs.imagemagick}/bin/magick -size 16x16 xc:#24273a $out
      ''
    );

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sizes = {
        applications = 12;
        terminal = 13;
        desktop = 11;
        popups = 11;
      };
    };
  };
}
