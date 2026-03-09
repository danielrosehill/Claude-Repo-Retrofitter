Evaluate the current repository and generate Claude Code subagents (`.claude/agents/`) tailored to its architecture and workflows.

Optional arguments (e.g. specific agent roles to create): $ARGUMENTS

---

## Step 1: Pre-flight Checks

1. Confirm you are inside a git repository (`git rev-parse --git-dir`). If not, stop and tell the user.
2. Run `git pull` to ensure the working tree is up to date.

---

## Step 2: Understand the Repository

Read the README, scan the file structure, and identify:

- **Purpose** — What does this project do?
- **Tech stack** — Languages, frameworks, key dependencies.
- **Architecture** — Is this a monorepo? Does it have distinct subsystems (frontend/backend, services, infra)? Are there clearly separable concerns?
- **Existing agents** — Check if `.claude/agents/` already exists. If it does, read the existing agents so you don't duplicate them.

Present a brief summary to the user:

```
Repository: <name>
Tech stack: <summary>
Architecture: <monorepo / single-app / library / etc.>
Existing agents: <list or "None">
```

---

## Step 3: Ensure CLAUDE.md Exists

If `CLAUDE.md` does not exist in the repo root, create it first. Subagents work best when the top-level agent has project context.

**CLAUDE.md** should contain:
- Project overview and purpose
- Tech stack and key dependencies
- Build, test, and lint commands
- Code conventions and patterns
- Repo-specific constraints

If `CLAUDE.md` already exists, leave it as-is.

---

## Step 4: Evaluate Whether Agents Are Appropriate

Not every repo benefits from subagents. Assess honestly:

**Good candidates for subagents:**
- Monorepos with distinct packages/services that have independent concerns
- Projects with separate frontend and backend codebases
- Repos with complex CI/CD or infrastructure alongside application code
- Projects with multiple distinct domains (e.g. API + worker + admin panel)
- Large codebases where scoping an agent to a subtree reduces context noise

**Poor candidates for subagents:**
- Single-purpose libraries or packages
- Small repos where one agent can handle everything
- Documentation-only repos
- Repos where all code is tightly coupled and can't be meaningfully separated

If the repo is NOT a good candidate, tell the user clearly:

```
This repository does not have a clear use case for subagents.
Reason: <explanation>

The main agent with CLAUDE.md is sufficient for this project.
```

Then stop — do not create agents just for the sake of it.

---

## Step 5: Design and Create Agents

If subagents ARE appropriate, create `.claude/agents/` (if it doesn't exist) and add markdown agent definition files.

**Each agent file** should contain:
- A clear role description at the top
- The scope of the codebase this agent is responsible for
- Key files and directories it should focus on
- Domain-specific knowledge relevant to its area
- Tools or MCP servers particularly relevant to its role
- Instructions on when to use this agent vs. the main agent

**Common agent patterns:**

| Architecture | Agents |
|-------------|--------|
| Frontend + Backend | `frontend.md`, `backend.md` |
| Monorepo with services | One agent per service (e.g. `api.md`, `worker.md`, `web.md`) |
| App + Infrastructure | `app.md`, `infra.md` |
| Core + Plugins | `core.md`, `plugins.md` |

**Workflow parallelization** — Design agents with parallel execution in mind:
- If the repo has workflows where multiple agents could work independently (e.g., frontend tests and backend tests, linting separate packages), note this in the agent definitions so the orchestrating agent knows to spawn them concurrently.
- Each agent should document which other agents it can run alongside without conflicts.
- Consider creating agents specifically to enable parallelism — e.g., if a monorepo has 3 independent packages, create per-package agents so they can be launched in parallel rather than one sequential agent doing all three.
- Include a "Parallelism notes" section in each agent file stating what this agent can run concurrently with.

**Naming convention:** Use lowercase kebab-case for filenames (e.g. `api-service.md`, `data-pipeline.md`).

**Keep agent count low.** 2–3 agents is typical. More than 4 is almost always too many.

### Reviewing Existing Agents

If `.claude/agents/` already has agents, don't just skip them — **review and optimize**:
- Read each existing agent file and evaluate its quality and scope
- Check whether agents could be restructured to enable better workflow parallelism
- Look for agents with overlapping scopes that should be consolidated
- Identify missing agents that would fill gaps or enable parallel workflows
- Verify that agent definitions reference correct paths and conventions
- Report what was reviewed, what was improved, and what was added

---

## Step 6: Commit and Push

1. Stage the new agent files (and CLAUDE.md if it was created).
2. Commit with the message: `Add Claude Code subagents`
3. Push to the remote.

---

## Step 7: Summary

Print what was created:

```
Subagents added to <repo-name>:

  agents/agent-name.md — role description
  agents/agent-name.md — role description
  ...

CLAUDE.md: <created / already existed>
```

Or if no agents were created:

```
No subagents created for <repo-name>.
Reason: <explanation>
```
