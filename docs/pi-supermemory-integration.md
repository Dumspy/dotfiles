# pi + SuperMemory Integration Plan

> How we will connect SuperMemory to the pi agent harness.

---

## The Problem

pi has **no built-in SuperMemory integration**. Setting `SUPERMEMORY_API_URL` does nothing — that environment variable is only consumed by the OpenCode TUI, not pi.

We need to build the integration ourselves. The good news: pi has a powerful extension API that lets us hook into the agent lifecycle, register custom tools, and inject context.

## Decision: Build Our Own

There is a [community extension (`ramarivera/pi-supermemory`)](https://github.com/ramarivera/pi-supermemory) that already implements SuperMemory for pi. We studied it as a reference for API usage, event hooks, and design patterns. However, we plan to **build and maintain our own extension** to have full control over behavior, scoping, and integration with our specific setup (self-hosted server, NixOS, Tailscale, OpenCode Go).

We may **fork the community extension** as a starting point, but the end goal is a fully owned implementation.

---

## Reference: How the OpenCode Plugin Works

The [opencode-supermemory](https://github.com/supermemoryai/opencode-supermemory) plugin is our reference architecture. It does five things:

1. **Context Injection** — Before every message, fetches the user profile + project memories + relevant memories and injects them into the system prompt
2. **Auto-Save (Keyword Detection)** — When the user says "remember", "save this", "don't forget", it auto-saves to memory
3. **Codebase Indexing** — `/supermemory-init` explores and memorizes the codebase structure
4. **Preemptive Compaction** — When context hits 80%, triggers OpenCode's summarization + saves the summary as a memory
5. **Tool API** — Provides a `supermemory` tool with `add`, `search`, `profile`, `list`, `forget` modes

---

## Our Approach: pi Extension

pi's extension API supports everything we need. We will build a TypeScript extension installed at `~/.pi/agent/extensions/supermemory.ts` (or as a pi package).

### Architecture

```
pi (agent harness)
    │
    ├─► input ──► capture user query for recall
    ├─► context ──► inject SuperMemory search results
    ├─► turn_end ──► auto-save "remember" keywords
    ├─► session_before_compact ──► save summary as memory
    │
    ├─► [LLM calls supermemory tool]
    │       ├─► search  ──► POST /v4/search
    │       ├─► save    ──► POST /v4/memories
    │       ├─► save_file ──► read file + POST /v4/memories
    │       └─► status  ──► show config
    │
    └─► /supermemory command ──► manual status/init
```

### Extension Responsibilities

Based on our research, the pi extension API exposes these key events for our use:

| Event | Action |
|-------|--------|
| `input` | Capture user input for later recall search queries |
| `context` | Inject SuperMemory search results as a user message before the LLM runs |
| `turn_end` | Detect "remember" keywords → auto-save the turn to memory |
| `session_before_compact` | Save compaction summary as a memory entry |
| `tool_call` | Execute the `supermemory` tool when the LLM calls it |
| `session_start` | Restore any extension state from session entries |

> **Note on `context` vs `before_agent_start`:** The community extension uses the `context` event (which fires after `before_agent_start`) to inject memories. The `context` event receives a deep copy of the message array, making it safer to modify. We'll follow this pattern.

### SuperMemory Tool Spec

The LLM will be able to call `supermemory` with these modes:

| Mode | Args | API Endpoint |
|------|------|-------------|
| `search` | `query`, `limit?` | `POST /v4/search` |
| `save` | `content`, `is_static?` | `POST /v4/memories` |
| `save_file` | `path`, `container_tag?` | Read file + `POST /v4/memories` |
| `status` | — | Show config |

---

## Context Injection Format

On the `context` event, the extension injects a synthetic user message before the actual messages:

```
Relevant Supermemory context from "pi-dotfiles":

1. Uses flakes for Nix configs
2. Deploys via deploy-rs
3. SuperMemory server runs on master-node
```

This is passed as a standard `user` role message in the messages array. The LLM sees it as context, but it's not displayed to the user in the pi TUI.

> **Reference pattern:** The community extension injects a `UserMessage` with the search results prepended to the actual messages array. We will follow this approach for maximum compatibility.

---

## Configuration

The extension will read from environment variables (aligned with our NixOS/1Password secrets pattern):

| Variable | Purpose | Default |
|----------|---------|---------|
| `SUPERMEMORY_API_KEY` | The `sm_...` key from first boot | Required |
| `SUPERMEMORY_API_BASE_URL` | Server URL | `http://master-node:6767` |
| `PI_SUPERMEMORY_CONTAINER_TAG` | Container for memories | `pi-supermemory` |
| `PI_SUPERMEMORY_MAX_RECALL` | Memories injected per turn | `5` |
| `PI_SUPERMEMORY_AUTO_RECALL` | Enable context injection | `true` |
| `PI_SUPERMEMORY_AUTO_CAPTURE` | Enable auto-save | `true` |
| `PI_SUPERMEMORY_CAPTURE_MODE` | `signal` (smart) or `all` | `signal` |

Future: we may add `.pi/supermemory.json` for project-local overrides, but v1 will be env-only for simplicity.

---

## Implementation Phases

### Phase 1: MVP Extension
- Register the `supermemory` tool with `search` and `save` modes
- Test against the self-hosted server on `master-node`
- Verify tool calls work from the LLM

### Phase 2: Context Injection
- Hook `input` to capture user queries
- Hook `context` to inject relevant memories before each LLM call
- Handle empty results gracefully

### Phase 3: Auto-Save
- Hook `turn_end` to detect "remember" / "save this" keywords
- Implement smart `signal` capture mode (skip low-signal turns)
- Strip injected SuperMemory context before saving to avoid recursion

### Phase 4: Polish
- Add `/supermemory` command for status and manual operations
- Add `save_file` tool for ingesting files
- Handle SuperMemory API chunking (10K char limit)
- Package as a pi package for distribution

### Reference: Community Extension Patterns

From studying `ramarivera/pi-supermemory`, these patterns are valuable:

| Pattern | Why We Adopt It |
|---------|----------------|
| `context` event over `before_agent_start` | Safer message mutation, deep copy provided |
| `input` event for query capture | Captures raw user text before any expansion |
| `turn_end` for auto-save | Fires after the full assistant response is complete |
| `cleanCaptureText()` | Strips injected context before saving, prevents recursion |
| `signal` vs `all` capture mode | Reduces noise, only saves meaningful turns |
| Chunking with overlap | Handles SuperMemory's ~10K content limit |
| Fingerprint deduplication | Prevents saving the same turn twice |
| `addDocument` API for turns | Uses `v3/documents` with metadata instead of `v4/memories` |

These patterns will inform our design but we will implement them independently.

---

## Key Differences from OpenCode Plugin

| OpenCode Plugin | pi Extension |
|-----------------|-------------|
| Written as an OpenCode plugin | Written as a pi extension |
| Uses `plugin` config | Uses `pi.registerTool()` + `pi.on()` |
| Has TUI commands (`/supermemory-init`) | Has pi commands (`/supermemory`) |
| Hooks into OpenCode's lifecycle | Hooks into pi's `context`, `turn_end`, etc. |

## Key Differences from Community Extension

| Community Extension | Our Extension |
|---------------------|-------------|
| Multiple config sources (env, JSON, rules) | v1: env only; simpler config |
| `supermemory_search` / `supermemory_save` tool names | `supermemory` tool with `mode` parameter |
| Uses `v3/documents` and `v4/memories` APIs | Will use `v4/search` + `v3/documents` |
| Hierarchical `.pi/supermemory.json` config | Future: may add project-local config |
| Full rule-based override system | Future: per-project container tags |

---

## Files to Create

| File | Purpose |
|------|---------|
| `~/.pi/agent/extensions/supermemory.ts` | The extension itself (or as a pi package) |
| `docs/pi-supermemory-integration.md` | This document |
| `docs/supermemory.md` | Server setup guide |

---

## Next Steps

1. Deploy the SuperMemory server to `master-node` (get the `sm_...` key)
2. Write the Phase 1 extension (`supermemory.ts`)
3. Test against the self-hosted server on `master-node`
4. Iterate through phases

---

## References

- [pi Extensions docs](https://github.com/...) — see `docs/extensions.md` in pi source
- [OpenCode SuperMemory plugin](https://github.com/supermemoryai/opencode-supermemory)
- [Community pi extension (`ramarivera/pi-supermemory`)](https://github.com/ramarivera/pi-supermemory) — studied as reference
- [SuperMemory API docs](https://supermemory.ai/docs/quickstart)
- [SuperMemory self-hosting docs](https://supermemory.ai/docs/self-hosting/overview)
