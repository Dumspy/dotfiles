---
name: dependabot-solver
description: Fetches Dependabot security alerts from a repository and returns structured data about packages with vulnerabilities, their severity, and minimum versions needed to resolve them. Use with an LLM to intelligently resolve dependency updates with proper version management.
---

# Dependabot Solver

Gathers Dependabot security alert data and structures it for LLM-driven resolution.

## Capabilities

- **Fetch Dependabot Alerts**: Query open Dependabot security alerts for a repository
- **Extract Vulnerability Info**: Get package names, ecosystems, severity levels, and patched versions
- **Structured Output**: Returns JSON with all alert details for LLM processing
- **Package Manager Detection**: Auto-detects npm, yarn, pnpm, pip, cargo, bundler, go
- **Strategy Definition**: Supports consolidated (single PR) or individual (per-alert) PR approaches

## Usage

### Basic Workflow

1. **Run from repository root**
   ```bash
    ~/.config/opencode/skill/dependabot-solver/scripts/dependabot-solver.sh [STRATEGY] [BASE_BRANCH]
   ```

2. **Script returns JSON with**
   - Alert details (package, severity, vulnerability info)
   - Minimum versions needed to resolve
   - Package manager type detected
   - Strategy (consolidated or individual)

3. **LLM processes output to**
   - Update dependencies to patched versions
   - Create appropriate PRs
   - Handle merge conflicts if needed

### Command Examples

```bash
# Get all alerts with default settings (consolidated, main branch)
~/.config/opencode/skill/dependabot-solver/scripts/dependabot-solver.sh

# Get alerts for individual PR strategy
~/.config/opencode/skill/dependabot-solver/scripts/dependabot-solver.sh individual main

# Parse and use output
ALERTS=$(~/.config/opencode/skill/dependabot-solver/scripts/dependabot-solver.sh | jq '.alerts')
PKG_MANAGER=$(~/.config/opencode/skill/dependabot-solver/scripts/dependabot-solver.sh | jq -r '.package_manager')
```

### Output Format

```json
{
  "repository": "owner/repo",
  "strategy": "consolidated",
  "base_branch": "main",
  "package_manager": "npm",
  "alert_count": 3,
  "alerts": [
    {
      "number": 1,
      "package_name": "lodash",
      "ecosystem": "npm",
      "severity": "high",
      "summary": "Prototype pollution in lodash",
      "vulnerabilities": [
        {
          "vulnerable_version_range": "< 4.17.21",
          "patched_versions": ["4.17.21", "4.17.22"]
        }
      ]
    }
  ]
}
```

## Skill Details

### Prerequisites
- Run in an already-cloned repository
- `gh` CLI installed and authenticated
- Git remote 'origin' configured
- Read access to repository for fetching alerts

### Parameters
- `STRATEGY`: `consolidated` (default) or `individual`
- `BASE_BRANCH`: Target branch name (default: `main`)

### LLM Integration

The script returns structured JSON that an LLM can process to:
1. Parse vulnerability details and patched versions
2. Update package.json/requirements.txt/etc. with minimum versions
3. Run appropriate install/update commands
4. Create branches and PRs with proper commit messages
5. Handle ecosystem-specific update logic

### Output
Returns JSON object with:
- Repository and strategy info
- Detected package manager
- Array of alerts with vulnerability details
- Patched versions for each vulnerability
