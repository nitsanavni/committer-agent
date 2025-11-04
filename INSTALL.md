# Installation Guide

This guide explains how to install the commit agent definitions in your projects.

## Installation Approach

Installation involves two steps:

1. **Add Submodule** - Add this repository as a git submodule to your project
2. **Activate** - Create symlinks from your project root to the agent definition directories

This approach allows you to:
- Keep agent definitions in sync across multiple projects
- Update all projects by updating the submodule
- Maintain a single source of truth for commit workflows

## Prerequisites

- Git (with submodule support)
- Bash or Zsh shell
- Unix-like environment (macOS, Linux, WSL)
- For Windows: Developer Mode enabled or administrator privileges (for symlinks)

## Installation Methods

### Automated (Recommended)

**Step 1: Add Submodule**

```bash
cd /path/to/your/project
git submodule add https://github.com/yourusername/committer-agent.git
git submodule update --init
```

**Step 2: Activate**

```bash
cd committer-agent
./activate.sh
```

The activation script will:
- Verify it's running from a git submodule
- Create symlinks from your project root to the agent definitions
- Verify the activation succeeded

**Step 3: Commit the Setup**

```bash
cd ..
git add .gitmodules committer-agent .cursor .claude
git commit -m "Add and activate commit agent definitions"
```

### Manual

If you prefer manual setup or need more control:

**Step 1: Add Submodule**

```bash
cd /path/to/your/project
git submodule add https://github.com/yourusername/committer-agent.git
```

**Step 2: Activate (Create Symlinks)**

```bash
# For Cursor
ln -s committer-agent/.cursor/rules .cursor/rules

# For Claude Code
ln -s committer-agent/.claude .claude
```

**Step 3: Verify Activation**

```bash
ls -la .cursor/rules
ls -la .claude
```

You should see output indicating these are symbolic links pointing to the submodule directories.

## Verification

After activation, verify the agent definitions are accessible:

### For Cursor

1. Open your project in Cursor
2. Try saying "commit" in the chat
3. The interactive commit agent should respond

### For Claude Code

1. Open your project in Claude Code
2. Type `/commit` in the chat
3. The interactive commit command should be available

## Troubleshooting

### "Not running from a git submodule" error

**Cause:** The activation script must be run from within the submodule directory.

**Solution:** Make sure you're in the `committer-agent` directory:
```bash
cd committer-agent
./activate.sh
```

### ".cursor/rules already exists" warning

**Cause:** Your project already has Cursor rules defined.

**Options:**
1. Backup existing rules: `mv .cursor/rules .cursor/rules.backup`
2. Manually merge the rules
3. Skip Cursor activation and only activate Claude Code definitions

### Symlinks not working on Windows

**Cause:** Windows requires special permissions for symlinks.

**Solutions:**
1. Enable Developer Mode in Windows Settings
2. Run terminal as Administrator
3. Use WSL (Windows Subsystem for Linux)
4. Alternative: Copy files instead of symlinking

### Cursor/Claude Code not recognizing the rules

**Cause:** Tools may need to be restarted to pick up new rules.

**Solution:**
1. Restart Cursor or Claude Code
2. Reload the window (Command/Ctrl + Shift + P → "Reload Window")
3. Close and reopen the project

## Deactivation and Removal

### Deactivate

To remove the agent definitions (symlinks only):

```bash
cd committer-agent
./deactivate.sh
```

This will:
- Remove the symlinks from your project root
- Keep the submodule itself (can be reactivated later)

### Remove Submodule

To completely remove the submodule:

```bash
cd ..
git submodule deinit -f committer-agent
git rm -f committer-agent
rm -rf .git/modules/committer-agent
git commit -m "Remove commit agent definitions submodule"
```

## Updating

To update the agent definitions across all projects:

```bash
# In any project using this submodule
cd committer-agent
git pull origin main
cd ..
git add committer-agent
git commit -m "Update commit agent definitions"
```

## Windows-Specific Notes

Windows users may encounter issues with symlinks. If symlinks don't work:

1. **Enable Developer Mode:**
   - Settings → Update & Security → For Developers
   - Turn on "Developer Mode"

2. **Use WSL:**
   - Install Windows Subsystem for Linux
   - Work within the Linux environment

3. **Copy instead of symlink:**
   - Manual approach: Copy directories instead of creating symlinks
   - Trade-off: Updates require manual re-copying

## Next Steps

After adding the submodule and activating:

1. Stage some files: `git add <file>`
2. Test interactive commit: Say "commit" in Cursor chat
3. Review the proposed commit message
4. Approve or edit as needed

For more information about the agent definitions themselves, see the project documentation.

