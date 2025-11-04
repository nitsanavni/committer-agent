# Shared Sections Convention

This document explains the convention used to manage duplicated content across the four agent definition files.

## Purpose

The four agent definitions share significant common content. Rather than using a build system or file includes, we use HTML comment markers to identify shared sections that must be kept in sync manually.

## Convention

Shared sections are marked with HTML comments:

```markdown
<!-- SHARED SECTION: section-name -->
<!-- If you change this, update all 4 agent definition files -->
[content here]
<!-- END SHARED SECTION -->
```

## Shared Sections

### 1. `commit-message-format`

**Content:** Commit message generation rules
**Location:** Step 2 of "Your Task" in all 4 files
**Rules:**
- First line < 60 characters
- Additional bullet points only if necessary
- Imperative mood style

### 2. `git-commands-interactive`

**Content:** Git commands for interactive workflow
**Location:** Step 1 of "Your Task" in interactive files
**Details:** Commands for analyzing staged changes, what to do if nothing staged
**Note:** Says "inform the user and stop"

### 3. `git-commands-autonomous`

**Content:** Git commands for autonomous workflow
**Location:** Step 1 of "Your Task" in autonomous files
**Details:** Commands for analyzing staged changes, what to do if nothing staged
**Note:** Says "report this and exit"

### 4. `important-rules-common`

**Content:** Core rules that apply to all workflows
**Location:** "Important Rules" section in all 4 files
**Rules:**
- Never stage files automatically
- Only work with staged changes
- Keep first line under 60 characters
- Be critical and thoughtful

**Note:** Workflow-specific rules (interactive vs autonomous) are placed outside this section.

### 5. `pre-commit-hooks`

**Content:** Pre-commit hook enforcement policy
**Location:** "Pre-Commit Hooks - NEVER BYPASS" section in all 4 files
**Rules:**
- Never use --no-verify or similar bypass flags
- All checks must pass or commit fails
- Code quality more important than successful commits

## Files Using This Convention

1. `.claude/commands/commit.md` - Claude Code interactive
2. `.claude/agents/committer.md` - Claude Code autonomous
3. `.cursor/rules/interactive-commit.mdc` - Cursor interactive
4. `.cursor/rules/autonomous-committer.mdc` - Cursor autonomous

## Workflow for Making Changes

### To Update Shared Content

1. Identify which shared section needs updating
2. Update the content in ONE file first
3. Copy the exact content (including spacing) to the same section in the other 3 files
4. Verify all 4 files have identical content in that section
5. Commit all 4 files together

### To Update Workflow-Specific Content

Simply edit the specific file without worrying about the others. Only content between the `<!-- SHARED SECTION -->` markers must be kept in sync.

## Inconsistencies Fixed

As of the most recent update, the following inconsistencies were resolved:

1. **Added TL;DR** to both Cursor files (was missing)
2. **Renamed** Claude's "Commit Command" to "Interactive Commit Command"
3. **Standardized introduction wording** across all files
4. **Added Usage sections** to all files for clarity
5. **Reordered** Important Rules to group common rules together

## Future Considerations

If maintaining sync becomes too burdensome, consider:
- Build script to assemble files from templates
- Automated tests to verify sections are identical
- Pre-commit hook to detect drift between shared sections

