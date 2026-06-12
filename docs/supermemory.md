# SuperMemory Self-Hosted Setup

> Personal memory server running on `master-node` via Tailscale, backed by OpenCode Go + DeepSeek V4 Flash.

---

## Overview

We run [SuperMemory](https://supermemory.ai) self-hosted on the `master-node` NixOS VM. The server is the single binary (`supermemory-server`) with all state embedded — no external database, no Docker, no Traefik.

Access is strictly over **Tailscale** at `http://master-node:6767` (or `http://100.83.126.36:6767`). No public internet exposure.

> **Note:** This guide uses three distinct tools — don't confuse them:
> - **pi** — the AI agent harness (this tool you're using right now)
> - **OpenCode** — the TUI-based AI coding assistant (separate terminal IDE)
> - **OpenCode Go** — the LLM subscription that provides model access (e.g., DeepSeek V4 Flash)

---

## Architecture

```
Your machines (via Tailscale)
         │
         ▼
┌─────────────────────────────────┐
│  master-node (100.83.126.36)    │
│                                 │
│  ┌───────────────────────────┐  │
│  │  supermemory-server       │  │
│  │  (:6767)                  │  │
│  │                           │  │
│  │  • graph DB               │  │
│  │  • embedding cache        │  │
│  │  • file storage           │  │
│  │  (/var/lib/supermemory)   │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │  Tailscale                │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
         │
         ▼
  OpenCode Go API
  (LLM provider)
```

---

## LLM Provider

| Setting | Value |
|---------|-------|
| **Provider** | [OpenCode Go](https://opencode.ai/go) |
| **Base URL** | `https://opencode.ai/zen/go/v1/chat/completions` |
| **Model** | `deepseek-v4-flash` |
| **Cost** | $5 first month, then $10/month |
| **Limits** | ~31,650 requests / 5h, ~158,150 / month |

The API key is stored in **1Password** (`NixSecrets` vault → `SuperMemory` item → `env` field).

---

## Deployment

### 1. Create the 1Password Secret

Before deploying, create the secret in 1Password:

```
Vault: NixSecrets
Item: SuperMemory
Field: env
Value:
  OPENAI_API_KEY=<your-opencode-go-api-key>
  OPENAI_BASE_URL=https://opencode.ai/zen/go/v1/chat/completions
  OPENAI_MODEL=deepseek-v4-flash
```

### 2. Deploy

```bash
cd ~/dotfiles
deploy .#master-node
```

### 3. Get the Generated API Key

After first boot, SuperMemory prints an API key. Extract it:

```bash
ssh deploy@100.83.126.36
sudo journalctl -u supermemory --no-pager | grep "api key"
```

Save the `sm_...` key — you will need it for every client.

### 4. Verify

```bash
# From any Tailscale-connected machine
curl http://master-node:6767/health 2>/dev/null || echo "Server not responding"
```

---

## Client Configuration

### pi (this agent harness)

**pi does not have built-in SuperMemory integration.** The `SUPERMEMORY_API_URL` environment variable does nothing for pi.

To use SuperMemory with pi, you would need to:
- Call the SuperMemory API directly in custom pi skills or code
- Or use the SuperMemory MCP server if pi supports MCP tools

pi uses `opencode-go` as its **LLM provider** (configured in `hosts/common/home.nix`), but that is unrelated to the SuperMemory memory layer.

### OpenCode (TUI)

OpenCode has **native SuperMemory integration**. Set the environment variable:

```bash
export SUPERMEMORY_API_URL=http://master-node:6767
```

Then launch the OpenCode TUI. OpenCode will automatically use your local SuperMemory server for memory/recall operations.

### Claude Code

```bash
export SUPERMEMORY_API_URL=http://master-node:6767
claude
```

### Claude Desktop (MCP)

### Claude Desktop (MCP)

```json
{
  "mcpServers": {
    "supermemory": {
      "url": "http://master-node:6767/mcp",
      "headers": {
        "Authorization": "Bearer sm_xxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

### Cursor / VS Code

Point the MCP server at:

```
http://master-node:6767/mcp
Authorization: Bearer sm_...
```

### General API

```typescript
import Supermemory from "supermemory"

const client = new Supermemory({
  apiKey: "sm_...",
  baseURL: "http://master-node:6767",
})
```

---

## Operations

### Check Status

```bash
ssh deploy@100.83.126.36
sudo systemctl status supermemory
sudo journalctl -u supermemory -f
```

### Restart

```bash
sudo systemctl restart supermemory
```

### Backup Data

```bash
# Local directory, easy to back up
ssh deploy@100.83.126.36
sudo tar czf /tmp/supermemory-backup.tar.gz /var/lib/supermemory
```

### Upgrade

Bump the version + sha256 in `packages/supermemory/default.nix`, then redeploy.

---

## Files

| File | Purpose |
|------|---------|
| `packages/supermemory/default.nix` | Download the binary |
| `modules/system/supermemory.nix` | NixOS module (systemd, user, hardening) |
| `hosts/master-node/system.nix` | Enable + configure for this host |
| `docs/supermemory.md` | This file |

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| "No API key configured" | Check 1Password secret exists and `opnix` synced it |
| Service fails to start | Check `journalctl -u supermemory` for first-boot wizard errors |
| Can't connect from client | Verify Tailscale on both machines: `tailscale ping master-node` |
| 403 / auth errors | Make sure you're using the `sm_...` key from first boot |

---

## Notes

- **No Traefik** — direct Tailscale access only. No HTTPS, no DNS name.
- **No k8s** — native NixOS systemd service. Simpler, no PVC overhead.
- **Firewall** — port `6767` is open on `master-node` for Tailscale connections.
- **Data** — everything lives in `/var/lib/supermemory`. One directory, easy to migrate.
