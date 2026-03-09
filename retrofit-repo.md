Your task is to update a repository in order to add several files which streamline the repository structure for use with AI coding agents.

## Important Constraints

- **No code changes.** You must not modify any existing source code, configuration files, or application logic in the target repository. Your only purpose is to add agent scaffolding files and push them back up.
- **Safety pull.** Before making any changes, always run `git pull` in the target repository to ensure you are working on the latest version and avoid conflicts.

## Repository Visibility Check

Before committing, determine whether the target repository is **public** or **private**:

1. Check using: `gh repo view --json isPrivate --jq '.isPrivate'` (run from within the target repo).
2. **If private**: Proceed normally. All files can be committed.
3. **If public**: Check `config.json` for a stored preference. If none, ask the user whether they want agent-specific files (`.claude/agents/`, `.claude/commands/`, `CLAUDE.md`, `AGENTS.md`) to be committed and open-sourced. If the user declines:
   - Add `.claude/` to `.gitignore`
   - Add `CLAUDE.md` and `AGENTS.md` to `.gitignore`
   - The scaffold folders (`context-data/`, `planning/`, `pm/`, `from-ai/`, `user-docs/`) can still be committed as they are general-purpose.

## Scaffolding to Add

### 1. Agent Guidance Files

Create these files in the target repository root:

**CLAUDE.md** — The primary agent guidance file. Should contain:
- Project overview and purpose (derived from existing README or code)
- Tech stack and key dependencies
- Build, test, and lint commands
- Code conventions and patterns used in the repo
- Any repo-specific constraints

**AGENTS.md** — A cross-framework agent reference. Should contain:
- Repository structure overview
- Key entry points and architecture notes
- Useful context for any AI agent working in the repo (not just Claude)

### 2. Scaffold Folders

Create these directories (with `.gitkeep` files so they're tracked):

- `context-data/` — Background information, research, reference material
- `planning/` — Project plans, roadmaps, design documents
- `pm/` — Project management artifacts, status updates
- `from-ai/` — AI-generated outputs, suggestions, analysis
- `user-docs/` — User-facing documentation drafts

If any of these folders already exist, skip them. If the repo already has equivalent directories (e.g. `docs/`), do not duplicate — just skip creating the overlap.

### 3. Slash Commands

Create `.claude/commands/` with markdown files appropriate for the repo type:

- Analyze the repo's purpose, language, and structure
- Create 2-4 relevant slash commands (e.g., `/review`, `/test`, `/deploy`, `/docs`)
- Each command file should contain clear instructions for the agent
- **Parallelization:** Actively look for workflows with independent steps that the command can instruct the agent to run concurrently (e.g., lint + test + type-check in parallel, validating multiple packages simultaneously, spawning parallel subagents for independent subsystems)
- If the repo already has commands, review and optimize them — check for missed parallelization opportunities, overly generic instructions, incorrect references, and workflow gaps

### 4. Subagents

If the repository would benefit from specialized agents, create `.claude/agents/` with markdown files defining them. Not every repo needs subagents — only add them when there's a clear use case (e.g., a monorepo with distinct subsystems, a project with separate frontend/backend concerns).

- **Parallelization:** Design agents to enable concurrent execution — if the repo has independent subsystems, create per-subsystem agents so they can be launched in parallel. Each agent should document what it can run concurrently with.
- If the repo already has agents, review and optimize them — check for missed parallelism opportunities, overlapping scopes, and incorrect references.

### 5. MCP Server Recommendations

Evaluate the repository and recommend MCP servers that would streamline working with it. Consider:

- **The repo's tech stack** — e.g., a repo using PostgreSQL might benefit from a database MCP; a repo deploying to Vercel might benefit from the Vercel MCP.
- **External services it integrates with** — APIs, cloud providers, CMS platforms, monitoring tools.
- **The repo's domain** — e.g., a data pipeline repo might benefit from a filesystem or S3 MCP; a web app might benefit from a browser-testing MCP.

Look for well-known, publicly available MCP servers. Don't force recommendations — if nothing is clearly useful, say so.

### 6. Custom Admin MCP Evaluation

Separately, evaluate whether the repository would benefit from a **lightweight custom MCP server** built specifically for managing or administering the project. This is a distinct question from recommending existing MCPs.

A custom admin MCP makes sense when:
- The repo has **repetitive operational tasks** (e.g., managing database migrations, rotating secrets, triggering deploys, checking service health).
- There are **project-specific queries** an agent would frequently need (e.g., fetching the latest build status, listing open feature flags, querying a custom API).
- The project involves **managing state or resources** that don't have good existing MCP coverage.

A custom admin MCP does NOT make sense when:
- The repo is a simple library or static site with no operational overhead.
- Existing MCPs already cover the needs.
- The operational tasks are rare or one-off.

If a custom MCP is recommended, briefly describe what it would do (2-4 key tools/resources it would expose).

### 7. Save Evaluation Report

Save a per-repo evaluation report to `working-data/reports/<repo-name>.md` in the **Retrofitter repository** (not the target repo). This report should contain:

- Repository name and path
- Date of evaluation
- Summary of what scaffolding was added
- MCP server recommendations (from step 5)
- Custom admin MCP evaluation (from step 6)
- Any other observations about the repo's agent-readiness

This report is for the user's future reference and is NOT committed to the target repo.

### 8. Append Retrofit Watermark

After all scaffolding is complete, append a watermark line to the bottom of the target repository's README (usually `README.md`). This allows future scans to detect that the repo has already been processed, even on a different machine.

Append this line (with a blank line before it):

```
*Repository evaluated by retrofit agent on YYYY-MM-DD*
```

Replace `YYYY-MM-DD` with the current date. If no README file exists, skip this step.

## Commit

After adding all scaffolding:

1. Stage all new files (respecting any `.gitignore` decisions).
2. Commit with the message: `Add AI agent scaffolding (retrofitted)`
3. Push to the remote.
