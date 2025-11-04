#!/bin/bash
set -e

# Colors for output (safe for non-terminal environments)
RED=$(tput setaf 1 2>/dev/null || echo '')
GREEN=$(tput setaf 2 2>/dev/null || echo '')
YELLOW=$(tput setaf 3 2>/dev/null || echo '')
NC=$(tput sgr0 2>/dev/null || echo '')

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

# Step 2: Check if symlinks exist and point to this submodule
CURSOR_LINK="$PARENT_REPO/.cursor/rules"
CLAUDE_LINK="$PARENT_REPO/.claude"

CURSOR_NEEDS_REMOVAL=false
CLAUDE_NEEDS_REMOVAL=false

echo "Checking activation status..."

# Check .cursor/rules
if [ -L "$CURSOR_LINK" ]; then
    CURSOR_TARGET=$(readlink "$CURSOR_LINK")
    if [[ "$CURSOR_TARGET" == *"$SUBMODULE_NAME"* ]]; then
        echo "${GREEN}✓${NC} .cursor/rules is activated (will be removed)"
        CURSOR_NEEDS_REMOVAL=true
    else
        echo "${YELLOW}ℹ${NC} .cursor/rules exists but points elsewhere (skipping)"
        echo "  Target: $CURSOR_TARGET"
    fi
elif [ -e "$CURSOR_LINK" ]; then
    echo "${YELLOW}ℹ${NC} .cursor/rules exists but is not a symlink (skipping)"
else
    echo "${GREEN}✓${NC} .cursor/rules not activated"
fi

# Check .claude
if [ -L "$CLAUDE_LINK" ]; then
    CLAUDE_TARGET=$(readlink "$CLAUDE_LINK")
    if [[ "$CLAUDE_TARGET" == *"$SUBMODULE_NAME"* ]]; then
        echo "${GREEN}✓${NC} .claude is activated (will be removed)"
        CLAUDE_NEEDS_REMOVAL=true
    else
        echo "${YELLOW}ℹ${NC} .claude exists but points elsewhere (skipping)"
        echo "  Target: $CLAUDE_TARGET"
    fi
elif [ -e "$CLAUDE_LINK" ]; then
    echo "${YELLOW}ℹ${NC} .claude exists but is not a symlink (skipping)"
else
    echo "${GREEN}✓${NC} .claude not activated"
fi

echo ""

# If nothing to remove, we're done (idempotent)
if [ "$CURSOR_NEEDS_REMOVAL" = false ] && [ "$CLAUDE_NEEDS_REMOVAL" = false ]; then
    echo "${GREEN}Already deactivated.${NC} Nothing to remove."
    echo ""
    exit 0
fi

# Step 3: Remove symlinks
echo "Deactivating..."

if [ "$CURSOR_NEEDS_REMOVAL" = true ]; then
    if rm "$CURSOR_LINK" 2>/dev/null; then
        echo "${GREEN}✓${NC} Removed .cursor/rules symlink"
    else
        echo "${RED}✗${NC} Failed to remove .cursor/rules symlink"
        exit 1
    fi
fi

if [ "$CLAUDE_NEEDS_REMOVAL" = true ]; then
    if rm "$CLAUDE_LINK" 2>/dev/null; then
        echo "${GREEN}✓${NC} Removed .claude symlink"
    else
        echo "${RED}✗${NC} Failed to remove .claude symlink"
        exit 1
    fi
fi

echo ""
echo "${GREEN}Deactivation successful!${NC}"
echo ""
echo "The agent definitions are now deactivated."
echo "You can reactivate by running: ./activate.sh"
echo ""
echo "To remove the submodule completely, run these commands from the parent repository:"
echo "  cd $PARENT_REPO"
echo "  git submodule deinit -f $SUBMODULE_NAME"
echo "  git rm -f $SUBMODULE_NAME"
echo "  rm -rf .git/modules/$SUBMODULE_NAME"
echo "  git commit -m \"Remove commit agent definitions submodule\""
echo ""

