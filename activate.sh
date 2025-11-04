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

# Step 3: Check if target locations already exist in parent
CURSOR_NEEDS_CREATION=true
CLAUDE_NEEDS_CREATION=true

# Check .cursor/rules
if [ -e "$PARENT_REPO/.cursor/rules" ]; then
    if [ -L "$PARENT_REPO/.cursor/rules" ]; then
        # It's a symlink - check if it points to the correct location
        LINK_TARGET=$(readlink "$PARENT_REPO/.cursor/rules")
        if [[ "$LINK_TARGET" == *"$SUBMODULE_NAME/.cursor/rules"* ]]; then
            echo "${GREEN}✓${NC} .cursor/rules already activated (correct symlink exists)"
            CURSOR_NEEDS_CREATION=false
        else
            echo "${RED}Error: .cursor/rules is a symlink to a different location${NC}"
            echo "  Current target: $LINK_TARGET"
            echo "  Expected: $SUBMODULE_NAME/.cursor/rules"
            echo ""
            echo "To proceed, remove the existing symlink first:"
            echo "  rm $PARENT_REPO/.cursor/rules"
            exit 1
        fi
    else
        # It exists but is not a symlink (regular file or directory)
        echo "${RED}Error: .cursor/rules already exists (not a symlink)${NC}"
        echo ""
        echo "To proceed, backup and remove the existing file/directory:"
        echo "  mv $PARENT_REPO/.cursor/rules $PARENT_REPO/.cursor/rules.backup"
        exit 1
    fi
fi

# Check .claude
if [ -e "$PARENT_REPO/.claude" ]; then
    if [ -L "$PARENT_REPO/.claude" ]; then
        # It's a symlink - check if it points to the correct location
        LINK_TARGET=$(readlink "$PARENT_REPO/.claude")
        if [[ "$LINK_TARGET" == *"$SUBMODULE_NAME/.claude"* ]]; then
            echo "${GREEN}✓${NC} .claude already activated (correct symlink exists)"
            CLAUDE_NEEDS_CREATION=false
        else
            echo "${RED}Error: .claude is a symlink to a different location${NC}"
            echo "  Current target: $LINK_TARGET"
            echo "  Expected: $SUBMODULE_NAME/.claude"
            echo ""
            echo "To proceed, remove the existing symlink first:"
            echo "  rm $PARENT_REPO/.claude"
            exit 1
        fi
    else
        # It exists but is not a symlink (regular file or directory)
        echo "${RED}Error: .claude already exists (not a symlink)${NC}"
        echo ""
        echo "To proceed, backup and remove the existing file/directory:"
        echo "  mv $PARENT_REPO/.claude $PARENT_REPO/.claude.backup"
        exit 1
    fi
fi

echo ""

# Step 4: Create .cursor directory if it doesn't exist
if [ ! -d "$PARENT_REPO/.cursor" ]; then
    echo "Creating .cursor directory..."
    mkdir -p "$PARENT_REPO/.cursor"
fi

# Step 5: Create symlinks (only if needed)
if [ "$CURSOR_NEEDS_CREATION" = true ] || [ "$CLAUDE_NEEDS_CREATION" = true ]; then
    echo "Creating symlinks..."
    
    # Cursor symlink (needs ../ since the symlink is inside .cursor directory)
    if [ "$CURSOR_NEEDS_CREATION" = true ]; then
        if ln -s "../$SUBMODULE_NAME/.cursor/rules" "$PARENT_REPO/.cursor/rules" 2>/dev/null; then
            echo "${GREEN}✓${NC} Created symlink: .cursor/rules -> ../$SUBMODULE_NAME/.cursor/rules"
        else
            echo "${RED}✗${NC} Failed to create Cursor symlink"
            exit 1
        fi
    fi
    
    # Claude Code symlink
    if [ "$CLAUDE_NEEDS_CREATION" = true ]; then
        if ln -s "$SUBMODULE_NAME/.claude" "$PARENT_REPO/.claude" 2>/dev/null; then
            echo "${GREEN}✓${NC} Created symlink: .claude -> $SUBMODULE_NAME/.claude"
        else
            echo "${RED}✗${NC} Failed to create Claude Code symlink"
            # Clean up Cursor symlink if Claude failed (only if we just created it)
            if [ "$CURSOR_NEEDS_CREATION" = true ]; then
                rm "$PARENT_REPO/.cursor/rules"
            fi
            exit 1
        fi
    fi
    
    echo ""
fi

# Step 6: Verify symlinks exist and work
echo "Verifying activation..."

if [ -L "$PARENT_REPO/.cursor/rules" ] && [ -d "$PARENT_REPO/.cursor/rules" ]; then
    echo "${GREEN}✓${NC} .cursor/rules is active and accessible"
else
    echo "${RED}✗${NC} .cursor/rules verification failed"
    exit 1
fi

if [ -L "$PARENT_REPO/.claude" ] && [ -d "$PARENT_REPO/.claude" ]; then
    echo "${GREEN}✓${NC} .claude is active and accessible"
else
    echo "${RED}✗${NC} .claude verification failed"
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

