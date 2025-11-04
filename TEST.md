# Testing Guide

**⚠️ NOTICE: This file was AI-generated without explicit request during a "move" operation and represents a 40x expansion from the original 5-bullet testing notes. Content has not been vetted and may contain useful information or gibberish.**

This document describes how to test the commit agent definitions.

## Test Philosophy

Test the agents deterministically to ensure they:
- Can be called and executed correctly
- Adhere to commit message rules
- Never bypass pre-commit hooks
- Never auto-stage files

## Manual Testing

### Basic Functionality Tests

**Test 1: Interactive Commit - Simple Change**

1. Make a small, simple change (e.g., update one file)
2. Stage the change: `git add <file>`
3. Trigger the agent:
   - **Cursor:** Say "commit" in chat
   - **Claude Code:** Type `/commit` in chat
4. Verify:
   - Agent analyzes the staged change
   - Proposes a commit message
   - First line is < 60 characters
   - Uses imperative mood
   - Waits for approval (yes/no/edit)
5. Test approval workflow:
   - Try "no" - should cancel
   - Try "edit" - should allow modification
   - Try "yes" - should commit

**Test 2: Interactive Commit - Complex Change**

1. Make multiple changes across several files
2. Stage changes: `git add .`
3. Trigger the agent
4. Verify:
   - Message summarizes all changes
   - First line < 60 characters
   - Includes bullet points if needed for multiple logical changes
   - Uses imperative mood

**Test 3: Interactive Commit - No Staged Files**

1. Ensure no files are staged: `git status`
2. Trigger the agent
3. Verify:
   - Agent detects no staged files
   - Provides clear message to user
   - Does NOT auto-stage files
   - Exits gracefully

**Test 4: Autonomous Commit**

1. Stage changes: `git add <file>`
2. Trigger autonomous agent:
   - **Cursor:** Say "act as autonomous committer"
   - **Claude Code:** Use Task tool
3. Verify:
   - Commits automatically without asking
   - Message follows same rules (< 60 chars, imperative)
   - Shows commit hash after success

### Pre-Commit Hook Tests

**Test 5: Pre-Commit Hook Failure**

1. Set up a failing pre-commit hook in your project
2. Stage changes: `git add <file>`
3. Trigger the agent (interactive or autonomous)
4. Verify:
   - Commit attempt fails
   - Agent reports the failure
   - Agent does NOT retry with `--no-verify`
   - Agent does NOT bypass the hook
   - User is informed to fix issues

**Test 6: Pre-Commit Hook Success**

1. Ensure pre-commit hooks will pass
2. Stage changes: `git add <file>`
3. Trigger the agent
4. Verify:
   - Hooks run normally
   - Commit succeeds
   - No bypass flags used

### Message Format Tests

**Test 7: First Line Length**

1. Make a change with a long description
2. Stage and trigger agent
3. Verify:
   - First line is under 60 characters
   - Additional details in bullet points if needed
   - Does not truncate important information

**Test 8: Imperative Mood**

1. Make various types of changes
2. Verify messages use imperative mood:
   - "Add feature" not "Added feature"
   - "Fix bug" not "Fixed bug"
   - "Update documentation" not "Updated documentation"

## Edge Cases

**Test 9: Binary Files**

1. Stage a binary file (image, PDF, etc.)
2. Trigger agent
3. Verify agent handles appropriately

**Test 10: Large Changesets**

1. Stage many files (e.g., 20+ files)
2. Trigger agent
3. Verify:
   - Message is concise
   - Summarizes changes appropriately
   - Still under 60 characters on first line

**Test 11: Merge Conflicts**

1. Create a merge conflict scenario
2. Stage resolved files
3. Trigger agent
4. Verify agent creates appropriate merge commit message

## Automated Testing Ideas

### Future Test Automation

Potential automated tests to implement:

1. **Unit Tests for Message Format**
   - Test message parser
   - Verify length constraints
   - Check imperative mood patterns

2. **Integration Tests**
   - Mock git operations
   - Test with various staged changes
   - Verify hook behavior

3. **Regression Tests**
   - Test against known good commits
   - Verify message quality over time

4. **Hook Bypass Detection**
   - Ensure `--no-verify` never used
   - Ensure `--no-gpg-sign` never used
   - Test with failing hooks

## Test Checklist

Use this checklist when testing changes to the agents:

- [ ] Interactive commit works in Cursor
- [ ] Interactive commit works in Claude Code
- [ ] Autonomous commit works in Cursor
- [ ] Autonomous commit works in Claude Code
- [ ] First line always < 60 characters
- [ ] Imperative mood used consistently
- [ ] No files auto-staged
- [ ] Pre-commit hooks run normally
- [ ] Hook failures cause commit to fail
- [ ] No bypass flags used
- [ ] "Edit" option works
- [ ] "No" option cancels cleanly
- [ ] Empty staging area handled gracefully
- [ ] Complex changesets summarized well

## Test Environment

**Setup:**
1. Test project with actual pre-commit hooks
2. Mix of file types (code, config, documentation)
3. Both simple and complex change scenarios

**Tools:**
- Cursor with agent rules activated
- Claude Code with agent commands available
- Git with hooks configured
- Sample pre-commit hook (linter, formatter, etc.)

## Reporting Issues

When reporting issues with the agents:

1. Describe the scenario (what was staged, what command was used)
2. Include the proposed commit message
3. Note any unexpected behavior
4. Specify which tool (Cursor/Claude Code) and workflow (interactive/autonomous)
5. Include any error messages

## Contributing Tests

To add new tests:

1. Update this document with the test case
2. Document expected behavior
3. Note any edge cases discovered
4. Update the test checklist if needed

