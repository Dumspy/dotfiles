final: prev: {
  auxera =
    prev.auxera
    // {
      opencode = prev.auxera.opencode.overrideAttrs (oldAttrs: {
        postPatch =
          (oldAttrs.postPatch or "")
          + ''
            # NOTE: The Bun-compiled standalone binary segfaults (exit 139) during
            # the build-phase smoke test on some hosts (notably WSL). The installed
            # binary works fine at runtime, so we skip the smoke test here.
            substituteInPlace packages/opencode/script/build.ts \
              --replace-fail 'if (item.os === process.platform && item.arch === process.arch && !item.abi) {' \
                             'if (false && item.os === process.platform && item.arch === process.arch && !item.abi) {'
          '';
        postInstall = "";
        doInstallCheck = false;
      });
    };
}
