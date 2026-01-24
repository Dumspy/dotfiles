{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  fetchNpmDepsWithPackuments,
  npmConfigHook,
  makeBinaryWrapper,
  nodejs,
}:
let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version rev hash npmDepsHash;
in
buildNpmPackage {
  inherit npmConfigHook version;
  pname = "dex";

  src = fetchFromGitHub {
    owner = "dcramer";
    repo = "dex";
    inherit rev hash;
  };

  npmDeps = fetchNpmDepsWithPackuments {
    src = fetchFromGitHub {
      owner = "dcramer";
      repo = "dex";
      inherit rev hash;
    };
    name = "dex-${version}-npm-deps";
    hash = npmDepsHash;
    fetcherVersion = 2;
    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';
  };

  makeCacheWritable = true;
  nativeBuildInputs = [makeBinaryWrapper];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/dex
    cp -r dist node_modules $out/share/dex/

    mkdir -p $out/etc/dex
    cp -r plugins/dex/skills $out/etc/dex/

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/dex \
      --add-flags "$out/share/dex/dist/index.js"
    runHook postInstall
  '';

  passthru.category = "Workflow & Project Management";

  meta = {
    description = "Task tracking for LLM workflows";
    homepage = "https://github.com/dcramer/dex";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [fromSource];
    mainProgram = "dex";
  };
}
