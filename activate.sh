#!/bin/bash
set -e

# Colors for output (safe for non-terminal environments)
RED=$(tput setaf 1 2>/dev/null || echo '')
GREEN=$(tput setaf 2 2>/dev/null || echo '')
YELLOW=$(tput setaf 3 2>/dev/null || echo '')
NC=$(tput sgr0 2>/dev/null || echo '')

echo "Commit Agent Activator"
echo "======================"
echo ""

# Step 1: Validate we're running from a submodule
echo "Checking if running from git submodule..."
PARENT_REPO=$(git rev-parse --show-superproject-working-tree 2>/dev/null)

if [ -z "$PARENT_REPO" ]; then
    echo "${RED}Error: Not running from a git submodule${NC}"
    echo ""
    echo "This script must be run from within the submodule directory."
    echo "Please ensure you've added this as a submodule first:"
    echo "  git submodule add <repo-url> committer-agent"
    echo ""
    exit 1
fi

echo "${GREEN}✓${NC} Running from submodule"
echo "${GREEN}✓${NC} Parent repository: $PARENT_REPO"
echo ""

# Step 2: Get submodule directory name
SUBMODULE_NAME=$(basename "$PWD")
echo "Submodule directory name: $SUBMODULE_NAME"
echo ""

# Step 3: Check if target directories already exist in parent
CURSOR_EXISTS=false
CLAUDE_EXISTS=false

if [ -e "$PARENT_REPO/.cursor/rules" ]; then
    CURSOR_EXISTS=true
    echo "${YELLOW}Warning: .cursor/rules already exists in parent repository${NC}"
fi

if [ -e "$PARENT_REPO/.claude" ]; then
    CLAUDE_EXISTS=true
    echo "${YELLOW}Warning: .claude already exists in parent repository${NC}"
fi

if [ "$CURSOR_EXISTS" = true ] || [ "$CLAUDE_EXISTS" = true ]; then
    echo ""
    echo "Existing directories detected. Options:"
    echo "  1. Backup and continue"
    echo "  2. Skip and exit"
    echo ""
    read -p "Enter choice (1 or 2): " choice
    
    case $choice in
        1)
            if [ "$CURSOR_EXISTS" = true ]; then
                echo "Backing up .cursor/rules to .cursor/rules.backup"
                mv "$PARENT_REPO/.cursor/rules" "$PARENT_REPO/.cursor/rules.backup"
            fi
            if [ "$CLAUDE_EXISTS" = true ]; then
                echo "Backing up .claude to .claude.backup"
                mv "$PARENT_REPO/.claude" "$PARENT_REPO/.claude.backup"
            fi
            echo ""
            ;;
        2)
            echo "Activation cancelled."
            exit 0
            ;;
        *)
            echo "${RED}Invalid choice. Activation cancelled.${NC}"
            exit 1
            ;;
    esac
fi

# Step 4: Create .cursor directory if it doesn't exist
if [ ! -d "$PARENT_REPO/.cursor" ]; then
    echo "Creating .cursor directory..."
    mkdir -p "$PARENT_REPO/.cursor"
fi

# Step 5: Create symlinks
echo "Creating symlinks..."

# Cursor symlink
if ln -s "$SUBMODULE_NAME/.cursor/rules" "$PARENT_REPO/.cursor/rules" 2>/dev/null; then
    echo "${GREEN}✓${NC} Created symlink: .cursor/rules -> $SUBMODULE_NAME/.cursor/rules"
else
    echo "${RED}✗${NC} Failed to create Cursor symlink"
    exit 1
fi

# Claude Code symlink
if ln -s "$SUBMODULE_NAME/.claude" "$PARENT_REPO/.claude" 2>/dev/null; then
    echo "${GREEN}✓${NC} Created symlink: .claude -> $SUBMODULE_NAME/.claude"
else
    echo "${RED}✗${NC} Failed to create Claude Code symlink"
    # Clean up Cursor symlink if Claude failed
    rm "$PARENT_REPO/.cursor/rules"
    exit 1
fi

echo ""

# Step 6: Verify symlinks
echo "Verifying symlinks..."

if [ -L "$PARENT_REPO/.cursor/rules" ] && [ -d "$PARENT_REPO/.cursor/rules" ]; then
    echo "${GREEN}✓${NC} .cursor/rules symlink verified"
else
    echo "${RED}✗${NC} .cursor/rules symlink verification failed"
    exit 1
fi

if [ -L "$PARENT_REPO/.claude" ] && [ -d "$PARENT_REPO/.claude" ]; then
    echo "${GREEN}✓${NC} .claude symlink verified"
else
    echo "${RED}✗${NC} .claude symlink verification failed"
    exit 1
fi

# Step 7: Success message
echo ""
echo "${GREEN}Activation successful!${NC}"
echo ""
echo "Next steps:"
echo "  1. Commit the setup:"
echo "     cd $PARENT_REPO"
echo "     git add .gitmodules $SUBMODULE_NAME .cursor .claude"
echo "     git commit -m \"Add and activate commit agent definitions\""
echo ""
echo "  2. Test the agents:"
echo "     - In Cursor: Say 'commit' in chat"
echo "     - In Claude Code: Type '/commit' in chat"
echo ""
echo "  3. Restart your editor if needed to pick up the new rules"
echo ""

