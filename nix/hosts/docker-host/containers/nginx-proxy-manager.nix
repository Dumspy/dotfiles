{ config, pkgs, ... }:
{
  image = "jc21/nginx-proxy-manager:latest";
  autoStart = true;
  ports = [ "80:80" "81:81" "443:443" ];
  volumes = [
    "/home/nixos/services/nginx-proxy-manager/data:/data"
    "/home/nixos/services/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
  ];
}