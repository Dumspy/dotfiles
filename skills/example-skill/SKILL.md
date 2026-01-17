---
name: example-skill
description: Example skill demonstrating proper OpenCode format and structure
license: MIT
compatibility: opencode
metadata:
  author: felix.berger
  category: template
  audience: developers
---

## What I do
- Demonstrate proper OpenCode skill format
- Show required YAML frontmatter structure
- Provide template for creating new skills
- Explain OpenCode skill naming conventions

## When to use me
Use this as a reference template when creating new OpenCode skills. Copy this directory and modify the content to create your own custom skills.

## Skill Structure
- Directory name must match `name` in frontmatter
- Only lowercase letters, numbers, and single hyphens
- SKILL.md must be in all caps
- Frontmatter must include `name` and `description`
- Description should be 1-1024 characters

## Next Steps
1. Copy this directory: `cp -r example-skill your-new-skill`
2. Edit `your-new-skill/SKILL.md` with your content
3. Add skill name to `nix/modules/home/agent-skills.nix`
4. Rebuild Home Manager to deploy the skill