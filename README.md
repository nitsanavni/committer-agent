# Commit Agent Definitions

AI agent definitions for generating thoughtful commit messages in Cursor and Claude Code.

## Overview

This repository provides agent definitions that help create high-quality git commit messages with:
- First line under 60 characters
- Imperative mood ("Add feature" not "Added feature")
- Automatic staging detection
- Pre-commit hook enforcement
- Interactive or autonomous workflows

## Features

**Two Tool Sets:**
- **Cursor** - Rules in `.cursor/rules/`
- **Claude Code** - Commands and agents in `.claude/`

**Two Workflows:**
- **Interactive** - Proposes commit message and waits for your approval
- **Autonomous** - Commits automatically without approval (explicit opt-in)

**Quality Enforcement:**
- Never bypasses pre-commit hooks
- Never auto-stages files
- Requires all linters and tests to pass
- Code quality over successful commits

## Quick Start

### Installation via Git Submodule

**Step 1: Add Submodule**

```bash
cd /path/to/your/project
git submodule add https://github.com/yourusername/committer-agent.git
```

**Step 2: Activate**

```bash
cd committer-agent
./activate.sh
```

**Step 3: Commit the Setup**

```bash
cd ..
git add .gitmodules committer-agent .cursor .claude
git commit -m "Add and activate commit agent definitions"
```

**Test it:**

```bash
# Stage some files
git add file.txt

# In Cursor: Say "commit" in chat
# In Claude Code: Type "/commit" in chat
```

For detailed instructions, see [INSTALL.md](INSTALL.md).

## Usage

### Interactive Workflow (Default)

**Cursor:**
1. Stage your changes with `git add`
2. In Cursor chat, say "commit" or "help me commit"
3. Review the proposed commit message
4. Respond with "yes", "no", or "edit"

**Claude Code:**
1. Stage your changes with `git add`
2. In Claude Code chat, type `/commit`
3. Review the proposed commit message
4. Respond with "yes", "no", or "edit"

### Autonomous Workflow (Explicit Opt-in)

**Cursor:**
1. Stage your changes with `git add`
2. In Cursor chat, say "act as autonomous committer"
3. The commit happens automatically

**Claude Code:**
1. Stage your changes with `git add`
2. Use the Task tool: `Task(subagent_type="committer", prompt="Commit the staged changes")`
3. The commit happens automatically

## Agent Definitions

This repository contains four agent definition files:

### Cursor Format

- `.cursor/rules/interactive-commit.mdc` - Interactive workflow
- `.cursor/rules/autonomous-committer.mdc` - Autonomous workflow

### Claude Code Format

- `.claude/commands/commit.md` - Interactive workflow
- `.claude/agents/committer.md` - Autonomous workflow

All four files maintain consistency through documented shared sections. See [SHARED-SECTIONS.md](SHARED-SECTIONS.md) for details on maintaining consistency.

## Development

### Historical Development

The Claude Code tools were created first by Monday Mob, with heavy input from Nitsan and Gregor. The Cursor tools were subsequently adapted (by Michael & Cursor) from the Claude originals to work within Cursor's rule system.

### Development Workflow

1. Update definitions in `.claude/` directory for Claude Code
2. Adapt to `.cursor/rules/` format for Cursor compatibility

### Maintaining Consistency

When updating shared content between the four files, see [SHARED-SECTIONS.md](SHARED-SECTIONS.md) for the convention used to mark and sync shared sections.

## Architecture

### Installation Flow

```
your-project/
├── .cursor/rules -> committer-agent/.cursor/rules (symlink)
├── .claude -> committer-agent/.claude (symlink)
└── committer-agent/ (git submodule)
    ├── .cursor/rules/
    │   ├── interactive-commit.mdc
    │   └── autonomous-committer.mdc
    └── .claude/
        ├── commands/commit.md
        └── agents/committer.md
```

### Why This Approach?

Using git submodules with symlinks (activation) allows:
- Single source of truth across multiple projects
- Easy updates by pulling the submodule
- Version control for agent definitions
- Ability to deactivate and reactivate as needed

## Requirements

- Git with submodule support
- Bash or Zsh shell
- Cursor or Claude Code editor
- Unix-like environment (macOS, Linux, WSL on Windows)

## Documentation

- [INSTALL.md](INSTALL.md) - Detailed installation instructions
- [SHARED-SECTIONS.md](SHARED-SECTIONS.md) - Maintaining consistency between agent files
- [plan.md](plan.md) - Project planning and testing notes

## Testing

See [plan.md](plan.md) for the testing plan.

Tests to verify:
- Agents can be called/executed
- Agents adhere to commit rules (< 60 chars, imperative mood)
- Pre-commit hooks are never bypassed
- No files are auto-staged

## Contributing

When making changes:

1. Update Claude Code definitions first (`.claude/`)
2. Adapt changes to Cursor format (`.cursor/rules/`)
3. Update shared section markers (see [SHARED-SECTIONS.md](SHARED-SECTIONS.md))
4. Test in both tools
5. Update documentation if needed

## License

[Add your license here]

## Credits

- **Original Claude Code agents:** Monday Mob (Nitsan, Gregor)
- **Cursor adaptation:** Michael & Cursor

