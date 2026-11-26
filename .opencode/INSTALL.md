# Installing Myskills in OpenCode

## V2 (opencode 2.x)

Add to `opencode.json`:

```json
{
  "plugin": ["<path-to-Myskills>/.opencode/plugins/myskills.js"]
}
```

The plugin's `setup()` registers every `skills/<name>/SKILL.md` as a native
skill via `ctx.skill.transform()`.

## V1 (opencode 1.x)

Same path. The named export `MyskillsPlugin` pushes the `skills/` directory
into `config.skills.paths`.

## Quick start

```bash
git clone https://github.com/K-arch-droid/Myskills.git ~/.opencode/myskills
```

```json
{
  "plugin": ["~/.opencode/myskills/.opencode/plugins/myskills.js"]
}
```

Then restart OpenCode.
