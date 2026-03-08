[![Part of the Claude Code Repos Index](https://img.shields.io/badge/Claude%20Code%20Repos-Index-blue?style=flat-square&logo=github)](https://github.com/danielrosehill/Claude-Code-Repos-Index)

# Claude Code Retrofitter

Bulk-retrofit existing repositories with AI agent scaffolding files. Designed for batch operations across large collections of repos — scan hundreds of repositories at once, identify which are missing scaffolding, and retrofit them in a single session.

While the scaffolding files use Claude Code conventions (CLAUDE.md, `.claude/commands/`, `.claude/agents/`), the patterns and folder structures are adaptable to other agentic coding frameworks and AI-assisted development workflows.

## How To Use

1. **Clone this repo** to your local machine:

```bash
git clone https://github.com/danielrosehill/Claude-Repo-Retrofitter.git
cd Claude-Repo-Retrofitter
```

2. **Open it in Claude Code** (or your preferred agentic CLI):

```bash
claude
```

3. **Run the scan slash command** to survey your repositories:

```
/scan ~/repos/github
```

This scans every git repo under the given path, generates a CSV and summary report, and presents you with a breakdown of which repos are missing scaffolding. You then choose which repos to retrofit.

4. **Or retrofit specific repos directly**:

```
/retrofit ~/repos/github/my-project ~/repos/github/another-project
```

5. **Or run in fully autonomous mode**:

```
/auto ~/repos/github
```

In autonomous mode, the agent scans every repo, evaluates whether it's a good candidate for scaffolding (skipping forks, empty repos, already-scaffolded repos), retrofits suitable ones, and pushes — all without user interaction.

The tool remembers your preferences (like your repo base path) in `config.json` and tracks which repos have already been processed in `scan-log.json`, so you can run incrementally without re-visiting repos.

## What Gets Added

Each retrofitted repo receives:

- **CLAUDE.md** - Top-level agent guidance file with project context and conventions
- **AGENTS.md** - Cross-framework agent reference (works beyond Claude Code)
- **Scaffold folders** - `context-data/`, `planning/`, `pm/`, `from-ai/`, `user-docs/`
- **Slash commands** - `.claude/commands/` with repo-appropriate commands
- **Subagents** - `.claude/agents/` if beneficial for the repo type

Additionally, the retrofitter generates a **per-repo evaluation report** saved locally in `working-data/reports/<repo-name>.md`. Each report includes:

- **MCP server recommendations** — existing public MCP servers that would complement the repo's tech stack and domain
- **Custom admin MCP assessment** — whether building a lightweight project-specific MCP server would help streamline repo operations, and if so, what tools it should expose

## Incremental Runs

The `scan-log.json` file tracks every repo that has been processed, along with its status (`retrofitted`, `skipped`, `not_suitable`, `error`, `already_complete`). On subsequent runs, already-visited repos are skipped automatically. This makes it safe to run `/auto` or `/scan` repeatedly across a growing collection of repos.

## Safety

- Runs `git pull` before changes
- Never modifies existing source code
- Checks public/private visibility and asks before open-sourcing agent files
- Stores user decisions in `config.json` to avoid repeated prompts
- Tracks visited repos in `scan-log.json` to avoid redundant work

---

For more Claude Code projects, visit [my index](https://github.com/danielrosehill/Claude-Code-Repos-Index).
