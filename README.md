# Claude-Repo-Retrofitter

Batch-retrofit existing repositories with Claude Code scaffolding (CLAUDE.md, AGENTS.md, slash commands, subagents, and project folders).

## Usage

### 1. Scan your repos

Run the scan script to identify which repositories are missing Claude elements:

```bash
./scan-repos.sh ~/repos/github
```

This generates a report in `./reports/` with categorized lists and a summary.

### 2. Use the slash commands

From within this repo in Claude Code:

- `/scan ~/repos/github` - Scan repos, view the report, and select which to retrofit
- `/retrofit /path/to/repo1 /path/to/repo2` - Retrofit specific repositories

### What gets added

Each retrofitted repo receives:

- **CLAUDE.md** - Top-level agent guidance file
- **AGENTS.md** - Cross-framework agent reference
- **Scaffold folders** - `context-data/`, `planning/`, `pm/`, `from-ai/`, `user-docs/`
- **Slash commands** - `.claude/commands/` with repo-appropriate commands
- **Subagents** - `.claude/agents/` if beneficial for the repo

### Safety

- Runs `git pull` before changes
- Never modifies existing source code
- Checks public/private visibility and asks before open-sourcing Claude files
