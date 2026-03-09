#!/bin/bash
# Install Claude-Repo-Retrofitter slash commands to ~/.claude/commands/
# These commands become available globally across all repositories.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/.claude/commands"
TARGET_DIR="$HOME/.claude/commands/retrofit"

# Standalone commands to install (not the batch-workspace ones)
COMMANDS=(
    "retrofit-this.md"
    "add-commands.md"
    "add-agents.md"
)

mkdir -p "$TARGET_DIR"

installed=0
for cmd in "${COMMANDS[@]}"; do
    if [ -f "$SOURCE_DIR/$cmd" ]; then
        cp "$SOURCE_DIR/$cmd" "$TARGET_DIR/$cmd"
        echo "  Installed: /retrofit:${cmd%.md}"
        installed=$((installed + 1))
    else
        echo "  Warning: $cmd not found in $SOURCE_DIR"
    fi
done

echo ""
echo "Installed $installed commands to $TARGET_DIR"
echo ""
echo "Available as:"
echo "  /retrofit:retrofit-this  — Full retrofit workflow for the current repo"
echo "  /retrofit:add-commands   — Add slash commands only"
echo "  /retrofit:add-agents     — Add subagents only"
