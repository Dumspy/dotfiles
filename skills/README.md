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

## Deployment

Skills are automatically deployed to `~/.config/opencode/skill/` via Home Manager activation using the `symlink-tree` structure, which preserves symlinks and keeps the skills directory in sync with your dotfiles configuration.
