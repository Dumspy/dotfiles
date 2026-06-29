# K3s Cluster Implementation Plan

## Overview

Set up a k3s cluster with 3 OCI nodes using Tailscale VPN for networking and opnix (1Password) for secret management.

### Cluster Architecture

| Node | Role | Tailscale IP | Architecture |
|------|------|--------------|--------------|
| oci-node-3 | Server (Controller) | 100.64.54.67 | aarch64-linux |
| oci-node-1 | Agent (Worker) | 100.99.30.112 | aarch64-linux |
| oci-node-2 | Agent (Worker) | 100.120.122.114 | aarch64-linux |

### Key Decisions

- **Ingress Controller:** Disabled (using Cloudflare tunnels)
- **Tools:** Mirror k3s-node (k9s, gcc, gnumake)
- **Storage:** Not configured yet
- **Secrets:** opnix with per-node configuration (Option B)
- **1Password Vault:** NixSecrets
- **Initial Token Setup:** Manual copy to 1Password

---

## Pre-Implementation Checks

### Verify opnix tokens exist on all OCI nodes

```bash
ssh deploy@100.64.54.67 "test -f /etc/opnix-token && echo 'oci-node-3: OK' || echo 'oci-node-3: MISSING'"
ssh deploy@100.99.30.112 "test -f /etc/opnix-token && echo 'oci-node-1: OK' || echo 'oci-node-1: MISSING'"
ssh deploy@100.120.122.114 "test -f /etc/opnix-token && echo 'oci-node-2: OK' || echo 'oci-node-2: MISSING'"
```

- [x] Run opnix token verification check
- [x] Confirm all three nodes return "OK"

---

## Files to Modify

| File | Purpose |
|------|---------|
| `modules/system/k3s.nix` | Add cluster configuration options |
| `hosts/oci-node-3/system.nix` | Configure as k3s server |
| `hosts/oci-node-1/system.nix` | Configure as k3s agent |
| `hosts/oci-node-2/system.nix` | Configure as k3s agent |

---

## Implementation Steps

### Step 1: Update `modules/system/k3s.nix`

#### Add new options (after line 18, after `role` option)

```nix
serverAddr = lib.mkOption {
  type = lib.types.nullOr lib.types.str;
  default = null;
  description = "Server URL for agents (e.g., https://100.64.54.67:6443)";
};

tokenFile = lib.mkOption {
  type = lib.types.nullOr lib.types.str;
  default = null;
  description = "Path to k3s cluster token file";
};

nodeIp = lib.mkOption {
  type = lib.types.nullOr lib.types.str;
  default = null;
  description = "Node IP address for k3s";
};

flannelIface = lib.mkOption {
  type = lib.types.str;
  default = "tailscale0";
  description = "Network interface for Flannel CNI";
};

extraFlags = lib.mkOption {
  type = lib.types.listOf lib.types.str;
  default = [];
  description = "Additional k3s CLI flags";
};
```

- [ ] Add new options to k3s module

#### Update service configuration (replace lines 21-24)

```nix
services.k3s = {
  enable = true;
  role = cfg.role;
  serverAddr = lib.mkIf (cfg.role == "agent" && cfg.serverAddr != null) cfg.serverAddr;
  tokenFile = lib.mkIf (cfg.role == "agent" && cfg.tokenFile != null) cfg.tokenFile;
  extraFlags = lib.lists.flatten [
    (lib.optional (cfg.nodeIp != null) "--node-ip=${cfg.nodeIp}")
    (lib.optional (cfg.nodeIp != null) "--node-external-ip=${cfg.nodeIp}")
    (lib.optional (cfg.flannelIface != "") "--flannel-iface=${cfg.flannelIface}")
    cfg.extraFlags
  ];
};
```

- [ ] Update services.k3s configuration with new options

#### Update firewall configuration (replace line 26)

```nix
networking.firewall.allowedTCPPorts = lib.mkIf (cfg.role == "server") [6443];
networking.firewall.allowedTCPPorts = lib.mkAfter (lib.optional true 8472);
networking.firewall.allowedUDPPorts = [8472 51820];
```

- [ ] Update firewall to include k3s cluster ports

---

### Step 2: Update `hosts/oci-node-3/system.nix` (Controller)

#### Add k3s configuration (after line 40, after `shell.default = "zsh";`)

```nix
k3s = {
  enable = true;
  role = "server";
  nodeIp = "100.64.54.67";
  flannelIface = "tailscale0";
  extraFlags = [
    "--tls-san=100.64.54.67"
    "--disable=traefik"
    "--write-kubeconfig-mode 0644"
  ];
};
```

- [ ] Add k3s server configuration to oci-node-3

#### Update packages (replace line 78)

```nix
environment.systemPackages = with pkgs; [git htop curl k9s gcc gnumake];
```

- [ ] Add k9s, gcc, gnumake to packages

#### Add KUBECONFIG environment variable (after line 79)

```nix
environment.variables = {
  KUBECONFIG = "$HOME/.kube/config";
};
```

- [ ] Set KUBECONFIG environment variable

#### Update firewall (replace lines 81-82)

```nix
networking.firewall.allowedTCPPorts = [22 41641 8888 6443 8472];
networking.firewall.allowedUDPPorts = [41641 8472 51820];
```

- [ ] Update firewall to include k3s ports

---

### Step 3: Update `hosts/oci-node-1/system.nix` (Worker 1)

#### Add k3s configuration (after line 37, after `shell.default = "zsh";`)

```nix
k3s = {
  enable = true;
  role = "agent";
  serverAddr = "https://100.64.54.67:6443";
  nodeIp = "100.99.30.112";
  flannelIface = "tailscale0";
  extraFlags = ["--node-external-ip=100.99.30.112"];
};
```

- [ ] Add k3s agent configuration to oci-node-1

#### Add opnix secret (after line 39, after `deploy.enable = true;`)

```nix
services.onepassword-secrets.secrets = {
  k3sToken = {
    reference = "op://NixSecrets/K3s/cluster-token";
    owner = "root";
    group = "root";
    services = ["k3s"];
  };
};
```

- [ ] Add opnix secret for k3s token

#### Add k3s tokenFile reference (after environment.variables section)

```nix
services.k3s.tokenFile = config.services.onepassword-secrets.secretPaths.k3sToken;
```

- [ ] Configure k3s to use opnix token

#### Update packages (replace line 87)

```nix
environment.systemPackages = with pkgs; [git htop curl k9s gcc gnumake];
```

- [ ] Add k9s, gcc, gnumake to packages

#### Add KUBECONFIG environment variable (after line 88)

```nix
environment.variables = {
  KUBECONFIG = "$HOME/.kube/config";
};
```

- [ ] Set KUBECONFIG environment variable

#### Update firewall (replace lines 90-91)

```nix
networking.firewall.allowedTCPPorts = [22 41641 8472];
networking.firewall.allowedUDPPorts = [41641 8472 51820];
```

- [ ] Update firewall to include k3s ports

---

### Step 4: Update `hosts/oci-node-2/system.nix` (Worker 2)

#### Add k3s configuration (after line 37, after `shell.default = "zsh";`)

```nix
k3s = {
  enable = true;
  role = "agent";
  serverAddr = "https://100.64.54.67:6443";
  nodeIp = "100.120.122.114";
  flannelIface = "tailscale0";
  extraFlags = ["--node-external-ip=100.120.122.114"];
};
```

- [ ] Add k3s agent configuration to oci-node-2

#### Add opnix secret (after line 39, after `deploy.enable = true;`)

```nix
services.onepassword-secrets.secrets = {
  k3sToken = {
    reference = "op://NixSecrets/K3s/cluster-token";
    owner = "root";
    group = "root";
    services = ["k3s"];
  };
};
```

- [ ] Add opnix secret for k3s token

#### Add k3s tokenFile reference (after environment.variables section)

```nix
services.k3s.tokenFile = config.services.onepassword-secrets.secretPaths.k3sToken;
```

- [ ] Configure k3s to use opnix token

#### Update packages (replace line 87)

```nix
environment.systemPackages = with pkgs; [git htop curl k9s gcc gnumake];
```

- [ ] Add k9s, gcc, gnumake to packages

#### Add KUBECONFIG environment variable (after line 88)

```nix
environment.variables = {
  KUBECONFIG = "$HOME/.kube/config";
};
```

- [ ] Set KUBECONFIG environment variable

#### Update firewall (replace lines 90-91)

```nix
networking.firewall.allowedTCPPorts = [22 41641 8472];
networking.firewall.allowedUDPPorts = [41641 8472 51820];
```

- [ ] Update firewall to include k3s ports

---

### Step 5: Format all modified files

```bash
alejandra modules/system/k3s.nix hosts/oci-node-{1,2,3}/system.nix
```

- [ ] Run alejandra to format all modified files

---

## Deployment Sequence

### Step 1: Deploy controller (oci-node-3)

```bash
deploy .#oci-node-3
```

- [ ] Deploy oci-node-3 (controller)

### Step 2: Verify controller and retrieve token

```bash
ssh deploy@100.64.54.67
```

```bash
sudo systemctl status k3s
```

- [ ] Verify k3s service is active on oci-node-3

```bash
sudo cat /var/lib/rancher/k3s/server/token
```

- [ ] Retrieve the k3s cluster token (copy this output)

### Step 3: Create 1Password entry

Create a new entry in 1Password:
- **Vault:** `NixSecrets`
- **Item:** `K3s`
- **Field:** `cluster-token`
- **Value:** Paste the token from Step 2

- [ ] Create K3s item in NixSecrets vault
- [ ] Add cluster-token field with the retrieved token

### Step 4: Deploy workers

```bash
deploy .#oci-node-1
```

- [ ] Deploy oci-node-1 (worker 1)

```bash
deploy .#oci-node-2
```

- [ ] Deploy oci-node-2 (worker 2)

### Step 5: Verify cluster

```bash
ssh deploy@100.64.54.67
```

```bash
sudo kubectl get nodes
```

Expected output:
```
NAME         STATUS   ROLES                  AGE   VERSION
oci-node-3   Ready    control-plane,master   Xs    vX.XX.X
oci-node-1   Ready    <none>                 Xs    vX.XX.X
oci-node-2   Ready    <none>                 Xs    vX.XX.X
```

- [ ] Verify all 3 nodes are in Ready state

```bash
sudo kubectl get pods -A
```

- [ ] Verify all system pods are running

---

## Verification Checklist

### Controller (oci-node-3)

```bash
ssh deploy@100.64.54.67
```

- [ ] k3s service is active: `sudo systemctl status k3s`
- [ ] All 3 nodes are Ready: `sudo kubectl get nodes`
- [ ] CoreDNS pods are running: `sudo kubectl get pods -n kube-system | grep coredns`
- [ ] Firewall allows required ports: `sudo nft list ruleset | grep -E '6443|8472|51820'`
- [ ] k9s can connect: `k9s` (should open and show cluster status)

### Worker 1 (oci-node-1)

```bash
ssh deploy@100.99.30.112
```

- [ ] k3s agent is running: `sudo systemctl status k3s`
- [ ] Logs show successful registration: `sudo journalctl -u k3s -n 50 | grep -i registered`

### Worker 2 (oci-node-2)

```bash
ssh deploy@100.120.122.114
```

- [ ] k3s agent is running: `sudo systemctl status k3s`
- [ ] Logs show successful registration: `sudo journalctl -u k3s -n 50 | grep -i registered`

---

## Port Reference

| Port | Protocol | Purpose | Nodes |
|------|----------|---------|-------|
| 6443 | TCP | Kubernetes API | Controller only |
| 8472 | TCP/UDP | Flannel VXLAN | All nodes |
| 51820 | UDP | Tailscale VPN | All nodes |
| 22 | TCP | SSH | All nodes |
| 41641 | TCP/UDP | Tailscale | All nodes |
| 8888 | TCP | Tinyproxy (oci-node-3) | Controller only |

---

## Troubleshooting

### Agent nodes fail to join cluster

**Check token file:**
```bash
ssh deploy@100.99.30.112
cat /var/lib/rancher/k3s/agent/token
```

**Check k3s agent logs:**
```bash
sudo journalctl -u k3s -n 100
```

**Verify Tailscale connectivity:**
```bash
tailscale ping 100.64.54.67
```

### Firewall issues

**Check firewall rules:**
```bash
sudo nft list ruleset
```

**Temporarily stop firewall for testing:**
```bash
sudo systemctl stop firewall
# Test k3s connection
sudo systemctl start firewall
```

### Opnix secrets not loading

**Check opnix service:**
```bash
sudo systemctl status onepassword-secrets
sudo journalctl -u onepassword-secrets -n 50
```

**Verify token file:**
```bash
cat /etc/opnix-token
```

**Check secret file exists:**
```bash
ls -la /var/lib/onepassword-secrets/
```

---

## Cleanup / Rollback

If deployment fails and you need to rollback:

```bash
# Rollback individual node
deploy --rollback .#oci-node-3
deploy --rollback .#oci-node-1
deploy --rollback .#oci-node-2
```

Or use magic rollback (automatic on failure):
- `magicRollback = true` is enabled in flake.nix for all OCI nodes

---

## Next Steps

After successful cluster deployment:

1. Configure Cloudflare tunnels for ingress
2. Set up storage solution (Longhorn, local-path, etc.)
3. Deploy monitoring stack (Prometheus, Grafana)
4. Configure backup/restore strategy
5. Set up GitOps with ArgoCD or Flux
