final: prev: {
  # Helm 4.x builds from source but the Nix derivation's substitute() step
  # references a test file (cmd/helm/dependency_build_test.go) that was removed
  # in the 4.x tree, causing the build to fail.  Skip the check phase since we
  # don't need Helm's test suite on workstation hosts.
  kubernetes-helm = prev.kubernetes-helm.overrideAttrs (oldAttrs: {
    doCheck = false;
    doInstallCheck = false;
  });
}
