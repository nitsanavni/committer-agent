# TODO

Feature requests and future enhancements for the commit agent definitions.

## Features to Implement

### Co-Author Detection and Management

Automatically detect and add co-authors to commit messages.

**Behavior:**

1. **Check recent commit** - If a commit was made in the previous 12 hours:
   - Reuse the co-author list from that commit
   - Present to user for confirmation

2. **Find contributors** - If no recent commit:
   - Query git log for previous 30 days
   - Count commits by each author
   - Sort by commit count (most active first)
   - Present list to user for selection

3. **User interaction:**
   - Multi-select interface to choose co-authors
   - Allow additions (manual entry)
   - Allow deletions (remove from list)

4. **Validation:**
   - Verify each co-author is a valid GitHub user
   - Check GitHub API before proceeding
   - Warn if user not found
   - Allow override if needed

5. **Commit message format:**
   ```
   Your commit message here
   
   - Change details
   - More changes
   
   Co-authored-by: Name <email@example.com>
   Co-authored-by: Name2 <email2@example.com>
   ```

**Implementation considerations:**
- Need GitHub API token for user validation
- Cache valid users to reduce API calls
- Handle GitHub API rate limits
- Store user preferences (default co-authors?)
- Support both interactive and autonomous modes

**Priority:** Medium

---

## Other Potential Features

### Commit Message Templates

Support for project-specific commit message templates.

**Priority:** Low

### Conventional Commits Support

Optional support for conventional commit format (feat:, fix:, docs:, etc.)

**Priority:** Low

### Commit Message Linting

Validate commit messages against configurable rules before committing.

**Priority:** Low

### Multi-language Support

Generate commit messages in different languages based on user preference.

**Priority:** Low

### AI Model Selection

Allow users to choose which AI model to use for commit message generation.

**Priority:** Low

---

## Maintenance Tasks

### Testing

- [ ] Create automated tests for agent definitions
- [ ] Test with various pre-commit hook configurations
- [ ] Test on Windows with symlinks
- [ ] Test in CI/CD environments

### Documentation

- [ ] Add video tutorials for installation
- [ ] Create troubleshooting flowchart
- [ ] Document common edge cases
- [ ] Add examples of good vs bad commit messages

### Code Quality

- [ ] Add shellcheck to CI for bash scripts
- [ ] Create validation script for shared sections consistency
- [ ] Add pre-commit hooks to this repository
- [ ] Document release process

---

## Completed

(Items will be moved here as they are completed)

---

## Notes

To add a new TODO item:
1. Add it to the appropriate section above
2. Include clear description of the feature/task
3. List implementation considerations
4. Assign a priority (High/Medium/Low)
4. Update this file in git

