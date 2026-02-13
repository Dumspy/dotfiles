{
  config,
  lib,
  kubeconfigClusters ? {},
  ...
}: let
  cfg = config.myModules.home.kubectl;
  portable = config.myModules.home.portable or false;
  aliasLines = lib.mapAttrsToList (_: clusterCfg: "alias -g ${clusterCfg.alias}='--context=${clusterCfg.contextName}'") kubeconfigClusters;
  aliasCode = lib.concatStringsSep "\n" aliasLines;
in {
  options.myModules.home.kubectl = {
    enable = lib.mkEnableOption "kubectl shell aliases for cluster contexts";
  };

  config = lib.mkIf (cfg.enable && kubeconfigClusters != {}) {
    programs.zsh.initContent = lib.mkIf (!portable) ''
      # Kubectl context aliases
      ${aliasCode}
    '';

    programs.fish.interactiveShellInit = lib.mkIf (!portable) ''
      # Kubectl context environment variables
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (_: clusterCfg: "set -gx ${clusterCfg.alias} '--context=${clusterCfg.contextName}'") kubeconfigClusters)}
    '';
  };
}
