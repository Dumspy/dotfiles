{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  glibc,
  gcc,
  openssl,
  version ? "0.0.3",
  sha256 ? "sha256-0mq95jckhm4ax11486ay1iamik3fqphl51lgkq4i2ddx2ijlhdj0",
}: let
  platform =
    if stdenv.hostPlatform.system == "x86_64-linux"
    then "linux-x64"
    else if stdenv.hostPlatform.system == "aarch64-linux"
    then "linux-arm64"
    else if stdenv.hostPlatform.system == "x86_64-darwin"
    then "darwin-x64"
    else if stdenv.hostPlatform.system == "aarch64-darwin"
    then "darwin-arm64"
    else throw "Unsupported platform: ${stdenv.hostPlatform.system}";
in
  stdenv.mkDerivation {
    pname = "supermemory-server";
    inherit version;

    src = fetchurl {
      url = "https://github.com/supermemoryai/supermemory/releases/download/server-v${version}/supermemory-server-${platform}";
      inherit sha256;
    };

    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [glibc gcc.cc.lib openssl];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp $src $out/bin/supermemory-server
      chmod +x $out/bin/supermemory-server
      runHook postInstall
    '';

    meta = {
      description = "Supermemory self-hosted memory server";
      homepage = "https://supermemory.ai";
      license = lib.licenses.mit;
      mainProgram = "supermemory-server";
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    };
  }
