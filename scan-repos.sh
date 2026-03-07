#!/bin/bash
# Scan a directory of git repositories and report which ones are missing
# Claude scaffolding elements (CLAUDE.md, .claude/commands, .claude/agents).
#
# Usage: ./scan-repos.sh /path/to/repos [output-dir]
#
# Output: Generates a report directory with categorized lists of repos.

set -euo pipefail

REPOS_BASE="${1:?Usage: ./scan-repos.sh /path/to/repos [output-dir]}"
OUTPUT_DIR="${2:-./working-data}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_DIR="${OUTPUT_DIR}/${TIMESTAMP}"
CSV_FILE="${OUTPUT_DIR}/scan-${TIMESTAMP}.csv"

if [ ! -d "$REPOS_BASE" ]; then
  echo "Error: '$REPOS_BASE' is not a directory."
  exit 1
fi

mkdir -p "$REPORT_DIR"

# CSV header
echo "repo,has_claude_md,has_commands,has_agents,status" > "$CSV_FILE"

# Arrays for categorization
missing_claude_md=()
missing_commands=()
missing_agents=()
missing_all=()
has_all=()

repo_count=0

for dir in "$REPOS_BASE"/*/; do
  # Skip non-git repos
  [ -d "${dir}.git" ] || continue

  repo_count=$((repo_count + 1))
  repo_name=$(basename "$dir")

  has_cm=false
  has_cmd=false
  has_agt=false

  [ -f "${dir}CLAUDE.md" ] && has_cm=true
  [ -d "${dir}.claude/commands" ] && [ "$(ls -A "${dir}.claude/commands" 2>/dev/null)" ] && has_cmd=true
  [ -d "${dir}.claude/agents" ] && [ "$(ls -A "${dir}.claude/agents" 2>/dev/null)" ] && has_agt=true

  if ! $has_cm; then missing_claude_md+=("$repo_name"); fi
  if ! $has_cmd; then missing_commands+=("$repo_name"); fi
  if ! $has_agt; then missing_agents+=("$repo_name"); fi

  if ! $has_cm && ! $has_cmd && ! $has_agt; then
    missing_all+=("$repo_name")
    status="missing_all"
  elif $has_cm && $has_cmd && $has_agt; then
    has_all+=("$repo_name")
    status="complete"
  else
    status="partial"
  fi

  # Write CSV row
  echo "${repo_name},${has_cm},${has_cmd},${has_agt},${status}" >> "$CSV_FILE"
done

# Write individual lists
printf '%s\n' "${missing_claude_md[@]}" > "$REPORT_DIR/missing-claude-md.txt" 2>/dev/null || touch "$REPORT_DIR/missing-claude-md.txt"
printf '%s\n' "${missing_commands[@]}" > "$REPORT_DIR/missing-commands.txt" 2>/dev/null || touch "$REPORT_DIR/missing-commands.txt"
printf '%s\n' "${missing_agents[@]}" > "$REPORT_DIR/missing-agents.txt" 2>/dev/null || touch "$REPORT_DIR/missing-agents.txt"
printf '%s\n' "${missing_all[@]}" > "$REPORT_DIR/missing-all-elements.txt" 2>/dev/null || touch "$REPORT_DIR/missing-all-elements.txt"
printf '%s\n' "${has_all[@]}" > "$REPORT_DIR/fully-scaffolded.txt" 2>/dev/null || touch "$REPORT_DIR/fully-scaffolded.txt"

# Write summary report
cat > "$REPORT_DIR/summary.md" <<EOF
# Claude Scaffolding Scan Report

**Scanned**: ${REPOS_BASE}
**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Total git repositories**: ${repo_count}

## Summary

| Element | Repos Missing | Repos Present |
|---|---|---|
| CLAUDE.md | ${#missing_claude_md[@]} | $((repo_count - ${#missing_claude_md[@]})) |
| .claude/commands | ${#missing_commands[@]} | $((repo_count - ${#missing_commands[@]})) |
| .claude/agents | ${#missing_agents[@]} | $((repo_count - ${#missing_agents[@]})) |

**Missing all elements**: ${#missing_all[@]}
**Fully scaffolded**: ${#has_all[@]}
**Partially scaffolded**: $((repo_count - ${#missing_all[@]} - ${#has_all[@]}))

## Repos Missing All Elements

$(printf -- '- %s\n' "${missing_all[@]}" 2>/dev/null || echo "_None_")

## Fully Scaffolded Repos

$(printf -- '- %s\n' "${has_all[@]}" 2>/dev/null || echo "_None_")
EOF

echo "Scan complete. ${repo_count} repos scanned."
echo "Report saved to: ${REPORT_DIR}/"
echo ""
echo "  Missing CLAUDE.md:        ${#missing_claude_md[@]}"
echo "  Missing slash commands:   ${#missing_commands[@]}"
echo "  Missing agents:           ${#missing_agents[@]}"
echo "  Missing all elements:     ${#missing_all[@]}"
echo "  Fully scaffolded:         ${#has_all[@]}"
echo ""
echo "CSV saved to: ${CSV_FILE}"
