#!/bin/bash
set -e

# Colors for output
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0) # No Color

echo "Commit Agent Deactivator"
echo "========================"
echo ""

# Step 1: Validate we're running from a submodule
echo "Checking if running from git submodule..."
PARENT_REPO=$(git rev-parse --show-superproject-working-tree 2>/dev/null)

if [ -z "$PARENT_REPO" ]; then
    echo "${RED}Error: Not running from a git submodule${NC}"
    echo ""
    echo "This script must be run from within the submodule directory."
    echo ""
    exit 1
fi

echo "${GREEN}✓${NC} Running from submodule"
echo "${GREEN}✓${NC} Parent repository: $PARENT_REPO"
echo ""

# Get submodule directory name
SUBMODULE_NAME=$(basename "$PWD")

# Step 2: Check if symlinks exist
CURSOR_LINK="$PARENT_REPO/.cursor/rules"
CLAUDE_LINK="$PARENT_REPO/.claude"

CURSOR_EXISTS=false
CLAUDE_EXISTS=false

if [ -L "$CURSOR_LINK" ]; then
    CURSOR_EXISTS=true
fi

if [ -L "$CLAUDE_LINK" ]; then
    CLAUDE_EXISTS=true
fi

if [ "$CURSOR_EXISTS" = false ] && [ "$CLAUDE_EXISTS" = false ]; then
    echo "${YELLOW}No symlinks found to remove.${NC}"
    echo ""
    exit 0
fi

# Step 3: Verify symlinks point to this submodule (safety check)
echo "Verifying symlinks..."

if [ "$CURSOR_EXISTS" = true ]; then
    CURSOR_TARGET=$(readlink "$CURSOR_LINK")
    if [[ "$CURSOR_TARGET" == *"$SUBMODULE_NAME"* ]]; then
        echo "${GREEN}✓${NC} .cursor/rules points to this submodule"
    else
        echo "${RED}✗${NC} .cursor/rules points elsewhere: $CURSOR_TARGET"
        echo "Skipping removal for safety."
        CURSOR_EXISTS=false
    fi
fi

if [ "$CLAUDE_EXISTS" = true ]; then
    CLAUDE_TARGET=$(readlink "$CLAUDE_LINK")
    if [[ "$CLAUDE_TARGET" == *"$SUBMODULE_NAME"* ]]; then
        echo "${GREEN}✓${NC} .claude points to this submodule"
    else
        echo "${RED}✗${NC} .claude points elsewhere: $CLAUDE_TARGET"
        echo "Skipping removal for safety."
        CLAUDE_EXISTS=false
    fi
fi

echo ""

if [ "$CURSOR_EXISTS" = false ] && [ "$CLAUDE_EXISTS" = false ]; then
    echo "No symlinks from this submodule to remove."
    exit 0
fi

# Step 4: Ask for confirmation
echo "The following symlinks will be removed:"
if [ "$CURSOR_EXISTS" = true ]; then
    echo "  - .cursor/rules"
fi
if [ "$CLAUDE_EXISTS" = true ]; then
    echo "  - .claude"
fi
echo ""

read -p "Continue? (y/N): " confirm
case $confirm in
    [yY]|[yY][eE][sS])
        ;;
    *)
        echo "Deactivation cancelled."
        exit 0
        ;;
esac

echo ""

# Step 5: Remove symlinks
echo "Removing symlinks..."

if [ "$CURSOR_EXISTS" = true ]; then
    if rm "$CURSOR_LINK" 2>/dev/null; then
        echo "${GREEN}✓${NC} Removed .cursor/rules symlink"
    else
        echo "${RED}✗${NC} Failed to remove .cursor/rules symlink"
    fi
fi

if [ "$CLAUDE_EXISTS" = true ]; then
    if rm "$CLAUDE_LINK" 2>/dev/null; then
        echo "${GREEN}✓${NC} Removed .claude symlink"
    else
        echo "${RED}✗${NC} Failed to remove .claude symlink"
    fi
fi

echo ""
echo "${GREEN}Deactivation successful!${NC}"
echo ""

# Step 6: Ask about removing submodule
read -p "Remove the submodule entirely? (y/N): " remove_submodule
case $remove_submodule in
    [yY]|[yY][eE][sS])
        echo ""
        echo "To remove the submodule completely, run these commands from the parent repository:"
        echo ""
        echo "  cd $PARENT_REPO"
        echo "  git submodule deinit -f $SUBMODULE_NAME"
        echo "  git rm -f $SUBMODULE_NAME"
        echo "  rm -rf .git/modules/$SUBMODULE_NAME"
        echo "  git commit -m \"Remove commit agent definitions submodule\""
        echo ""
        ;;
    *)
        echo ""
        echo "Symlinks removed. Submodule remains."
        echo "You can reactivate by running ./activate.sh"
        echo ""
        ;;
esac

