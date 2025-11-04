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

# Step 3: Define agent files to symlink (parallel arrays for bash 3.2 compatibility)
TARGET_FILES=(
    ".claude/commands/commit.md"
    ".claude/agents/committer.md"
    ".cursor/rules/interactive-commit.mdc"
    ".cursor/rules/autonomous-committer.mdc"
)

LINK_TARGETS=(
    "../../$SUBMODULE_NAME/.claude/commands/commit.md"
    "../../$SUBMODULE_NAME/.claude/agents/committer.md"
    "../../$SUBMODULE_NAME/.cursor/rules/interactive-commit.mdc"
    "../../$SUBMODULE_NAME/.cursor/rules/autonomous-committer.mdc"
)

# Track which files need creation
FILES_NEED_CREATION=()

# Check each file
for i in "${!TARGET_FILES[@]}"; do
    TARGET_FILE="${TARGET_FILES[$i]}"
    EXPECTED_LINK="${LINK_TARGETS[$i]}"
    FULL_PATH="$PARENT_REPO/$TARGET_FILE"
    
    if [ -e "$FULL_PATH" ]; then
        if [ -L "$FULL_PATH" ]; then
            # It's a symlink - check if it points to the correct location
            LINK_TARGET=$(readlink "$FULL_PATH")
            if [[ "$LINK_TARGET" == "$EXPECTED_LINK" ]]; then
                echo "${GREEN}✓${NC} $TARGET_FILE already activated (correct symlink exists)"
            else
                echo "${RED}Error: $TARGET_FILE is a symlink to a different location${NC}"
                echo "  Current target: $LINK_TARGET"
                echo "  Expected: $EXPECTED_LINK"
                echo ""
                echo "To proceed, remove the existing symlink first:"
                echo "  rm $FULL_PATH"
                exit 1
            fi
        else
            # It exists but is not a symlink (regular file or directory)
            echo "${RED}Error: $TARGET_FILE already exists (not a symlink)${NC}"
            echo ""
            echo "To proceed, backup and remove the existing file/directory:"
            echo "  mv $FULL_PATH ${FULL_PATH}.backup"
            exit 1
        fi
    else
        FILES_NEED_CREATION+=("$i")
    fi
done

echo ""

# Step 4: Create parent directories if they don't exist
echo "Creating parent directories..."
mkdir -p "$PARENT_REPO/.claude/commands"
mkdir -p "$PARENT_REPO/.claude/agents"
mkdir -p "$PARENT_REPO/.cursor/rules"
echo ""

# Step 5: Create symlinks (only if needed)
CREATED_FILES=()
ANY_CREATED=false

for idx in "${FILES_NEED_CREATION[@]}"; do
    if [ "$ANY_CREATED" = false ]; then
        echo "Creating symlinks..."
        ANY_CREATED=true
    fi
    
    TARGET_FILE="${TARGET_FILES[$idx]}"
    LINK_TARGET="${LINK_TARGETS[$idx]}"
    FULL_PATH="$PARENT_REPO/$TARGET_FILE"
    
    if ln -s "$LINK_TARGET" "$FULL_PATH" 2>/dev/null; then
        echo "${GREEN}✓${NC} Created symlink: $TARGET_FILE -> $LINK_TARGET"
        CREATED_FILES+=("$FULL_PATH")
    else
        echo "${RED}✗${NC} Failed to create symlink: $TARGET_FILE"
        # Clean up any symlinks we created before failing
        for CREATED in "${CREATED_FILES[@]}"; do
            rm "$CREATED"
        done
        exit 1
    fi
done

if [ "$ANY_CREATED" = true ]; then
    echo ""
fi

# Step 6: Verify symlinks exist and work
echo "Verifying activation..."

for TARGET_FILE in "${TARGET_FILES[@]}"; do
    FULL_PATH="$PARENT_REPO/$TARGET_FILE"
    if [ -L "$FULL_PATH" ] && [ -f "$FULL_PATH" ]; then
        echo "${GREEN}✓${NC} $TARGET_FILE is active and accessible"
    else
        echo "${RED}✗${NC} $TARGET_FILE verification failed"
        exit 1
    fi
done

# Step 7: Success message
echo ""
echo "${GREEN}Activation successful!${NC}"
echo ""
echo "Next steps:"
echo "  1. Commit the setup:"
echo "     cd $PARENT_REPO"
echo "     git add .gitmodules $SUBMODULE_NAME .claude .cursor"
echo "     git commit -m \"Add and activate commit agent definitions\""
echo ""
echo "  2. Test the agents:"
echo "     - In Cursor: Say 'commit' in chat"
echo "     - In Claude Code: Type '/commit' in chat"
echo ""
echo "  3. Restart your editor if needed to pick up the new rules"
echo ""

