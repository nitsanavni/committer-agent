# Committer Agent - Overview

This repository contains commit message generation agents for two different tool sets with two different workflows.

## Two Tool Sets

1. **Claude Code** - Original files in [.claude/](.claude/)
2. **Cursor** - Adapted files in [.cursor/rules/](.cursor/rules/)

## Two Workflows

1. **Interactive** - Proposes commit message and waits for user approval
2. **Autonomous** - Commits automatically without approval

## Definition Files

### Claude Code Format

- [.claude/commands/commit.md](.claude/commands/commit.md) - Interactive workflow
- [.claude/agents/committer.md](.claude/agents/committer.md) - Autonomous workflow

### Cursor Format

- [.cursor/rules/interactive-commit.mdc](.cursor/rules/interactive-commit.mdc) - Interactive workflow
- [.cursor/rules/autonomous-committer.mdc](.cursor/rules/autonomous-committer.mdc) - Autonomous workflow

## Installation

### Claude Code

1. Copy the `.claude/` directory to your project root
2. Claude Code will automatically detect and load the commands and agents

### Cursor

1. Copy the `.cursor/rules/` directory to your project root
2. Restart Cursor or reload the window
3. The rules will be automatically loaded and available

## Usage

### Claude Code

**Interactive Workflow:**
1. Stage your changes with `git add`
2. In Claude Code chat, type `/commit`
3. Review the proposed commit message
4. Respond with "yes", "no", or "edit"

**Autonomous Workflow:**
1. Stage your changes with `git add`
2. Use the Task tool: `Task(subagent_type="committer", prompt="Commit the staged changes")`
3. The commit happens automatically without approval

### Cursor

**Interactive Workflow:**
1. Stage your changes with `git add`
2. In Cursor chat, type "commit" or "help me commit"
3. Review the proposed commit message
4. Respond with "yes", "no", or "edit"

**Autonomous Workflow:**
1. Stage your changes with `git add`
2. In Cursor chat, explicitly request: "act as autonomous committer" or "commit without approval"
3. The commit happens automatically

## Historical Development

The Claude Code tools were created first by Monday Mob, with heavy input from Nitsan and Gregor. The Cursor tools were subsequently adapted (by Michael & cursor) from the Claude originals to work within Cursor's rule system.

### Development Work Flow

1. Update definitions created in `.claude/` directory for Claude Code
2. Adapted to `.cursor/rules/` format for Cursor compatibility

## Testing Plan

A reminder, maybe we can test deterministically the committers.

tests:
- it (the slash cmd, the sub-agent) can be called / executed
- it adheres to our commit rules

Next, we could try:
- the slash cmd with bigger change (not easily summarized)
- try the sub-agent