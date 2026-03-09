Retrofit the current repository with AI agent scaffolding — a single, self-contained workflow that evaluates, scaffolds, commits, and pushes.

Optional arguments (e.g. visibility preference): $ARGUMENTS

---

## Step 1: Pre-flight Checks

1. Confirm you are inside a git repository (`git rev-parse --git-dir`). If not, stop and tell the user.
2. Run `git pull` to ensure the working tree is up to date.
3. Check whether this repo has already been retrofitted:
   - Look for the watermark `*Repository evaluated by retrofit agent on ...*` in the README.
   - If found, inform the user and ask whether to proceed anyway or abort.

---

## Step 2: Repository Evaluation

Read the README, scan the file structure, and assess:

- **Purpose & tech stack** — What does this project do? What languages, frameworks, and tools does it use?
- **Existing scaffolding** — Does it already have `CLAUDE.md`, `AGENTS.md`, `.claude/commands/`, `.claude/agents/`, or scaffold folders?
- **Suitability** — Is this a real project that would benefit from agent scaffolding? (Skip if it's an empty repo, a bare fork with no local changes, or a trivial single-file script.)

Present a brief evaluation summary to the user before proceeding:

```
Repository: <name>
Path: <path>
Visibility: public / private
Tech stack: <summary>
Existing scaffolding: <what's already present, or "None">
Recommendation: <retrofit / already complete / not suitable>
```

If not suitable, explain why and stop. If already complete, switch to **review and optimize mode** (see below) rather than re-scaffolding from scratch. Otherwise, proceed.

### Review and Optimize Mode

When the repo already has scaffolding (CLAUDE.md, commands, agents, etc.), don't skip or overwrite — instead review and improve the existing implementation:

1. **CLAUDE.md / AGENTS.md** — Read and check for missing sections, outdated info, or inaccuracies. Fill gaps without overwriting good content.
2. **Slash commands** — Review each existing command for:
   - Missed parallelization opportunities (sequential steps that could run concurrently)
   - Overly generic instructions that should be tailored to the repo
   - Incorrect file paths, tool references, or conventions
   - Missing commands that would fill workflow gaps
3. **Subagents** — Review each existing agent for:
   - Opportunities to restructure for better parallel execution
   - Overlapping scopes that should be consolidated
   - Missing agents that would enable parallel workflows
   - Incorrect or outdated scope definitions
4. **Report** what was reviewed, what was changed, and what was added.

---

## Step 3: Visibility Check

Determine whether the repository is public or private:

```bash
gh repo view --json isPrivate --jq '.isPrivate'
```

- **Private**: All files can be committed.
- **Public**: Ask the user whether they want agent-specific files (`.claude/`, `CLAUDE.md`, `AGENTS.md`) committed and open-sourced.
  - If the user **approves**, commit everything.
  - If the user **declines**, add to `.gitignore`:
    ```
    # AI agent files (kept local for this public repo)
    .claude/
    CLAUDE.md
    AGENTS.md
    ```
  - Scaffold folders (`context-data/`, `planning/`, `pm/`, `from-ai/`, `user-docs/`) can always be committed.

---

## Step 4: Add Scaffolding

**Important constraint: Do NOT modify any existing source code, configuration files, or application logic. Only add new scaffolding files.**

### 4a. Agent Guidance Files

**CLAUDE.md** — Primary agent guidance file. Derive content by reading the repo:
- Project overview and purpose
- Tech stack and key dependencies
- Build, test, and lint commands (find them in package.json, Makefile, pyproject.toml, etc.)
- Code conventions and patterns
- Repo-specific constraints

**AGENTS.md** — Cross-framework agent reference:
- Repository structure overview
- Key entry points and architecture notes
- Context useful for any AI agent (not just Claude)

If either file already exists, read it and only fill in missing sections — do not overwrite existing content.

### 4b. Scaffold Folders

Create these directories with `.gitkeep` files (skip any that already exist or have equivalents):

- `context-data/` — Background information, research, reference material
- `planning/` — Project plans, roadmaps, design documents
- `pm/` — Project management artifacts
- `from-ai/` — AI-generated outputs and analysis
- `user-docs/` — User-facing documentation drafts

### 4c. Slash Commands

Create `.claude/commands/` with 2–4 markdown files appropriate for the repo's type, language, and purpose. Examples:
- `/review` — code review guidance
- `/test` — run and analyze tests
- `/deploy` — deployment workflow
- `/docs` — generate or update documentation

Tailor them to the actual project. Each file should contain clear instructions for the agent.

**Parallelization:** Design commands that exploit parallel execution where possible. If a workflow has independent steps (lint + test + type-check, validating multiple packages, checking multiple services), the command should instruct the agent to run them concurrently using parallel tool calls or spawning parallel subagents.

If commands already exist, review and optimize them rather than skipping — check for missed parallelization, generic instructions, and workflow gaps.

### 4d. Subagents

Only create `.claude/agents/` if there's a clear use case:
- Monorepo with distinct subsystems
- Separate frontend/backend concerns
- Complex CI/CD or infrastructure alongside application code

Design agents to enable parallel execution — if the repo has independent subsystems, create per-subsystem agents so they can be launched concurrently. Each agent should document what it can run in parallel with.

If agents already exist, review and optimize them rather than skipping — check for missed parallelism opportunities and overlapping scopes.

Most repos do NOT need subagents. Skip this if unsure.

---

## Step 5: MCP Server Recommendations

Evaluate the repo and recommend existing public MCP servers that would be useful. Consider:
- The tech stack (databases, cloud providers, APIs)
- External service integrations
- The project's domain

Don't force recommendations. If nothing clearly fits, say so.

---

## Step 6: Custom Admin MCP Evaluation

Separately evaluate whether a lightweight custom MCP server would benefit this project.

**Good candidates**: Repos with repetitive operational tasks, project-specific queries, or resource management not covered by existing MCPs.

**Not good candidates**: Simple libraries, static sites, or repos where existing MCPs suffice.

If recommended, describe 2–4 key tools/resources it would expose.

---

## Step 7: Append Retrofit Watermark

Append to the bottom of the target repo's README (e.g. `README.md`), with a blank line before it:

```
*Repository evaluated by retrofit agent on YYYY-MM-DD*
```

Use the current date. If no README exists, skip this step.

---

## Step 8: Commit and Push

1. Stage all new files (respect `.gitignore` decisions from Step 3).
2. Commit with the message: `Add AI agent scaffolding (retrofitted)`
3. Push to the remote.

---

## Step 9: Summary

Print a final summary:

```
Retrofit complete: <repo-name>

Scaffolding added:
  - CLAUDE.md
  - AGENTS.md
  - Scaffold folders: context-data/, planning/, pm/, from-ai/, user-docs/
  - Slash commands: /review, /test, ...
  - Subagents: (none / list)

MCP recommendations: (summary or "None")
Custom admin MCP: (recommended / not recommended)
```
