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

# Step 2: Define agent files to check (bash 3.2 compatible)
TARGET_FILES=(
    ".claude/commands/commit.md"
    ".claude/agents/committer.md"
    ".cursor/rules/interactive-commit.mdc"
    ".cursor/rules/autonomous-committer.mdc"
)

# Track which files need removal
FILES_TO_REMOVE=()

echo "Checking activation status..."

for TARGET_FILE in "${TARGET_FILES[@]}"; do
    FULL_PATH="$PARENT_REPO/$TARGET_FILE"
    
    if [ -L "$FULL_PATH" ]; then
        LINK_TARGET=$(readlink "$FULL_PATH")
        if [[ "$LINK_TARGET" == *"$SUBMODULE_NAME"* ]]; then
            echo "${GREEN}✓${NC} $TARGET_FILE is activated (will be removed)"
            FILES_TO_REMOVE+=("$FULL_PATH")
        else
            echo "${YELLOW}ℹ${NC} $TARGET_FILE exists but points elsewhere (skipping)"
            echo "  Target: $LINK_TARGET"
        fi
    elif [ -e "$FULL_PATH" ]; then
        echo "${YELLOW}ℹ${NC} $TARGET_FILE exists but is not a symlink (skipping)"
    else
        echo "${GREEN}✓${NC} $TARGET_FILE not activated"
    fi
done

echo ""

# If nothing to remove, we're done (idempotent)
if [ ${#FILES_TO_REMOVE[@]} -eq 0 ]; then
    echo "${GREEN}Already deactivated.${NC} Nothing to remove."
    echo ""
    exit 0
fi

# Step 3: Remove symlinks
echo "Deactivating..."

for FILE_PATH in "${FILES_TO_REMOVE[@]}"; do
    if rm "$FILE_PATH" 2>/dev/null; then
        # Get relative path from parent repo for display
        REL_PATH="${FILE_PATH#$PARENT_REPO/}"
        echo "${GREEN}✓${NC} Removed $REL_PATH symlink"
    else
        echo "${RED}✗${NC} Failed to remove symlink: $FILE_PATH"
        exit 1
    fi
done

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

