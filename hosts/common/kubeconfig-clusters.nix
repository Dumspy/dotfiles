{...}: {
  myModules.system.kubeconfig = {
    enable = true;
    clusters = {
      k3sNode = {
        reference = "op://NixSecrets/k3s-node-kubeconfig/kube-config";
        contextName = "k3s-node";
        alias = "K3S";
      };
      ociCluster = {
        reference = "op://NixSecrets/oci-cluster-kubeconfig/kube-config";
        contextName = "oci-cluster";
        alias = "OCI";
      };
    };
  };
}
