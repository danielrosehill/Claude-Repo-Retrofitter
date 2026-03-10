[![Part of the Claude Code Repos Index](https://img.shields.io/badge/Claude%20Code%20Repos-Index-blue?style=flat-square&logo=github)](https://github.com/danielrosehill/Claude-Code-Repos-Index)

# Repo Retrofitter — Claude Code Plugin

Bulk-retrofit existing repositories with AI agent scaffolding files. Designed for batch operations across large collections of repos — scan hundreds of repositories at once, identify which are missing scaffolding, and retrofit them in a single session.

While the scaffolding files use Claude Code conventions (CLAUDE.md, `.claude/commands/`, `.claude/agents/`), the patterns and folder structures are adaptable to other agentic coding frameworks and AI-assisted development workflows.

## Installation

Install the plugin directly from GitHub:

```bash
claude plugin install repo-retrofitter@danielrosehill/Claude-Code-Plugins
```

Or load it locally during development:

```bash
claude --plugin-dir /path/to/Claude-Repo-Retrofitter
```

Once installed, all skills are available as `/repo-retrofitter:<skill-name>`.

## Skills

| Skill | Command | Description |
|-------|---------|-------------|
| **scan** | `/repo-retrofitter:scan ~/repos` | Scan repos and report missing scaffolding |
| **retrofit** | `/repo-retrofitter:retrofit ~/repos/project-a ~/repos/project-b` | Retrofit specific repositories |
| **retrofit-this** | `/repo-retrofitter:retrofit-this` | Retrofit the current repository |
| **interactive** | `/repo-retrofitter:interactive ~/repos` | Guided repo-by-repo approval with parallel execution |
| **auto** | `/repo-retrofitter:auto ~/repos` | Fully autonomous scan, evaluate, and retrofit |
| **add-commands** | `/repo-retrofitter:add-commands` | Add slash commands to the current repo |
| **add-agents** | `/repo-retrofitter:add-agents` | Add subagents to the current repo |

## What Gets Added

Each retrofitted repo receives:

- **CLAUDE.md** - Top-level agent guidance file with project context and conventions
- **AGENTS.md** - Cross-framework agent reference (works beyond Claude Code)
- **Scaffold folders** - `context-data/`, `planning/`, `pm/`, `from-ai/`, `user-docs/`
- **Slash commands** - `.claude/commands/` with repo-appropriate commands
- **Subagents** - `.claude/agents/` if beneficial for the repo type
- **MCP recommendations** - Suggested public MCP servers for the repo's tech stack
- **Custom MCP evaluation** - Whether a project-specific admin MCP would help

## State Files

The plugin uses two optional state files in your working directory:

- **`config.json`** — Stores user preferences (repo base path, visibility defaults, skip list). Created on first run.
- **`scan-log.json`** — Tracks which repos have been processed. Enables incremental runs so you can run `/repo-retrofitter:auto` repeatedly without re-visiting repos.

## Safety

- Runs `git pull` before making changes
- Never modifies existing source code
- Checks public/private visibility and asks before open-sourcing agent files
- Stores user decisions to avoid repeated prompts
- Tracks visited repos to avoid redundant work

---

For more Claude Code projects, visit [my index](https://github.com/danielrosehill/Claude-Code-Repos-Index).
