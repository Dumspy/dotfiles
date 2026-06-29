{config, ...}: {
  # Agent nodes pull the k3s cluster token from 1Password and reach the
  # cluster + internet through the server node (oci-node-3).
  myModules.system = {
    onepassword.enable = true;
    k3s = {
      role = "agent";
      serverAddr = "https://10.0.1.215:6443";
    };
  };

  services.onepassword-secrets.secrets = {
    k3sToken = {
      reference = "op://OCI-Secrets/cluster-token/credential";
      owner = "root";
      group = "root";
      services = ["k3s"];
    };
  };

  services.k3s.tokenFile = config.services.onepassword-secrets.secretPaths.k3sToken;

  # Proxy configuration via oci-node-3 (tinyproxy on :8888)
  networking.proxy.default = "http://10.0.1.215:8888";
  networking.proxy.noProxy = "localhost,127.0.0.1,10.0.1.0/24";

  systemd.globalEnvironment = {
    HTTP_PROXY = "http://10.0.1.215:8888";
    HTTPS_PROXY = "http://10.0.1.215:8888";
    NO_PROXY = "localhost,127.0.0.1,10.0.1.0/24";
  };
}
