# OpenCode Skills

This directory contains custom OpenCode skills for use with agent-skills-nix.

## Directory Structure

```
skills/
├── README.md                 # This file
├── skill-name/              # One directory per skill
│   └── SKILL.md             # Skill definition with frontmatter
└── another-skill/
    └── SKILL.md
```

## Skill Format

Each skill directory must contain a `SKILL.md` file with proper YAML frontmatter:

```markdown
---
name: skill-name
description: Brief description (1-1024 characters)
license: MIT                    # Optional
compatibility: opencode         # Optional
metadata:                       # Optional
  author: your-name
  category: utility
---

## What I do
- Skill functionality description
- What the skill can accomplish

## When to use me
Use this when you need specific functionality.
```

## Naming Rules

Skill names (directory names) must:
- Be 1-64 characters
- Be lowercase alphanumeric with single hyphen separators
- Not start or end with `-`
- Not contain consecutive `--`
- Match regex: `^[a-z0-9]+(-[a-z0-9]+)*$`

## Adding New Skills

1. Create directory: `skills/my-new-skill/`
2. Create `skills/my-new-skill/SKILL.md` with proper format
3. Add skill name to `nix/modules/home/agent-skills.nix`:
   ```nix
   skills.enable = [ "my-new-skill" ];
   ```
4. Rebuild Home Manager or run `home-manager switch`

## External Skill Sources

To add external skill repositories:

1. Add flake input in `nix/flake.nix`:
   ```nix
   inputs.my-skills = {
     url = "github:username/skills-repo";
     flake = false;
   };
   ```

2. Configure source in `nix/modules/home/agent-skills.nix`:
   ```nix
   sources.my-skills = {
     path = inputs.my-skills;
     subdir = "skills";
   };
   ```

3. Add skills from that source to enable list.

These skills are automatically enabled and available to OpenCode.

## Converting Claude Plugin Repositories

Many repositories like `expo/skills` are designed as Claude Code plugins but can be converted to work with OpenCode. Here's how:

### Directory Structure Differences

**Claude Code plugins:**
```
repo/
├── plugins/
│   └── plugin-name/
│       ├── README.md
│       ├── .claude-plugin/
│       └── skills/
│           └── skill-name/
│               └── SKILL.md
```

**OpenCode skills:**
```
repo/
└── skills/
    └── skill-name/
        └── SKILL.md
```

### Conversion Steps

1. **Add the repository as a flake input:**
   ```nix
   inputs.my-plugin = {
     url = "github:username/repo";
     flake = false;
   };
   ```

2. **Configure multiple sources for nested skills:**
   ```nix
   sources.plugin-name-1 = {
     path = inputs.my-plugin;
     subdir = "plugins/plugin-name-1/skills";
   };
   
   sources.plugin-name-2 = {
     path = inputs.my-plugin; 
     subdir = "plugins/plugin-name-2/skills";
   };
   ```

3. **Enable individual skills:**
   ```nix
   skills.enable = [
     "skill-name-from-plugin-1",
     "skill-name-from-plugin-2",
   ];
   ```

### Finding Available Skills

Use GitHub API to discover skills in Claude plugin repositories:

```bash
# List plugins
curl -s "https://api.github.com/repos/username/repo/contents/plugins" | grep -o '"name": *"[^"]*"'

# List skills in a plugin
curl -s "https://api.github.com/repos/username/repo/contents/plugins/plugin-name/skills" | grep -o '"name": *"[^"]*"'
```

### Compatibility Notes

- ✅ **SKILL.md files work directly** - Both systems use the same format
- ✅ **YAML frontmatter** - `name`, `description`, `license` fields are compatible
- ❌ **README.md files** - Claude plugin docs need separate SKILL.md files
- ❌ **Complex directory structures** - Require multiple source configurations

This approach lets you leverage Claude Code plugin ecosystems while maintaining OpenCode compatibility.

## Deployment

Skills are automatically deployed to `~/.config/opencode/skill/` via Home Manager activation using the `symlink-tree` structure, which preserves symlinks and keeps the skills directory in sync with your dotfiles configuration.
