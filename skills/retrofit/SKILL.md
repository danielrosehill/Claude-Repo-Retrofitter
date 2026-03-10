---
name: retrofit
description: Retrofit one or more repositories with AI agent scaffolding
---

Retrofit one or more repositories with AI agent scaffolding.

The user will provide one or more absolute paths to target repositories. For example: $ARGUMENTS

## Before Starting

Look for a `config.json` in the current working directory for stored user preferences (base path, visibility defaults, repos to skip). Use these to avoid re-asking questions the user has already answered.

## For each target repository path:

### 1. Skip Check

If the repository name appears in the `skip_repos` list in `config.json`, skip it silently and move to the next.

### 2. Safety Pull

Navigate to the target repository and run `git pull` to ensure you are on the latest version before making any changes.

### 3. Verify No Code Changes Policy

You must NOT modify any existing source code, configuration files, or application logic. Your only job is to add agent scaffolding files and push the result.

### 4. Repository Visibility Check

Determine whether the repository is public or private:

```bash
gh repo view --json isPrivate --jq '.isPrivate'
```

- **If private**: All files can be committed freely.
- **If public**: Check `default_visibility_action` in `config.json`.
  - If set to `"open_source"`, commit all files without asking.
  - If set to `"gitignore"`, add agent files to `.gitignore` without asking.
  - If empty, ask the user whether they want the agent files (`.claude/`, `CLAUDE.md`, `AGENTS.md`) to be committed and open-sourced. Offer to remember their choice for future repos.
  - If the user **declines**, add the following to `.gitignore`:
    ```
    # AI agent files (kept local for this public repo)
    .claude/
    CLAUDE.md
    AGENTS.md
    ```
  - The scaffold folders (`context-data/`, `planning/`, `pm/`, `from-ai/`, `user-docs/`) can still be committed as they are general-purpose.

### 5. Add or Review Scaffolding

Apply the full retrofitting process to the target repository:

#### Agent Guidance Files

**CLAUDE.md** — The primary agent guidance file. Derive content by reading the repo:
- Project overview and purpose
- Tech stack and key dependencies
- Build, test, and lint commands (find them in package.json, Makefile, pyproject.toml, etc.)
- Code conventions and patterns
- Repo-specific constraints

**AGENTS.md** — A cross-framework agent reference:
- Repository structure overview
- Key entry points and architecture notes
- Useful context for any AI agent (not just Claude)

If either file already exists, read it and only fill in missing sections — do not overwrite existing content.

#### Scaffold Folders

Create these directories with `.gitkeep` files (skip any that already exist or have equivalents):

- `context-data/` — Background information, research, reference material
- `planning/` — Project plans, roadmaps, design documents
- `pm/` — Project management artifacts
- `from-ai/` — AI-generated outputs and analysis
- `user-docs/` — User-facing documentation drafts

#### Slash Commands

Create `.claude/commands/` with 2–4 markdown files appropriate for the repo's type, language, and purpose. Tailor them to the actual project.

**Parallelization:** Design commands that exploit parallel execution where possible. If a workflow has independent steps (lint + test + type-check, validating multiple packages, checking multiple services), the command should instruct the agent to run them concurrently.

If commands already exist, review and optimize them rather than skipping.

#### Subagents

Only create `.claude/agents/` if there's a clear use case (monorepo with distinct subsystems, separate frontend/backend concerns, complex CI/CD alongside application code). Design agents to enable parallel execution.

Most repos do NOT need subagents. Skip this if unsure.

#### MCP Server Recommendations

Evaluate the repo and recommend existing public MCP servers that would be useful. Don't force recommendations — if nothing clearly fits, say so.

#### Custom Admin MCP Evaluation

Evaluate whether a lightweight custom MCP server would benefit this project. If recommended, describe 2–4 key tools it would expose.

**If the repo already has scaffolding**, switch to **review and optimize mode** — don't skip or overwrite. Instead:
- Review existing CLAUDE.md/AGENTS.md for missing sections or outdated info
- Review existing slash commands for missed parallelization opportunities, generic instructions, incorrect references, and workflow gaps
- Review existing agents for parallelism improvements and overlapping scopes
- Add any missing scaffolding components
- Report what was reviewed, improved, and added

### 6. Append Retrofit Watermark

Append a watermark line to the bottom of the target repo's README (e.g. `README.md`) so future scans can detect this repo was already processed. Add a blank line then:

```
*Repository evaluated by retrofit agent on YYYY-MM-DD*
```

Use the current date. If no README exists, skip this step.

### 7. Commit and Push (Target Repo)

1. Stage all new files (respect the `.gitignore` decisions from step 4).
2. Commit with the message: `Add AI agent scaffolding (retrofitted)`
3. If `auto_push` is true in `config.json`, push automatically. Otherwise ask the user.

### 8. Update Scan Log

After successfully retrofitting (or skipping) a repo, update `scan-log.json` in the current working directory with an entry for the repo:

```json
{
  "status": "retrofitted",
  "timestamp": "2026-03-08T12:00:00Z",
  "visibility": "public|private|unknown"
}
```

Create the file if it doesn't exist.

### 9. Repeat

If multiple repository paths were provided, repeat steps 1-8 for each one. Report a summary at the end showing which repos were retrofitted, any that were skipped.
