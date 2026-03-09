Generate and add Claude Code slash commands to the current repository, tailored to its purpose and tech stack.

Optional arguments (e.g. specific commands to create): $ARGUMENTS

---

## Step 1: Pre-flight Checks

1. Confirm you are inside a git repository (`git rev-parse --git-dir`). If not, stop and tell the user.
2. Run `git pull` to ensure the working tree is up to date.

---

## Step 2: Understand the Repository

Read the README, scan the file structure, and identify:

- **Purpose** — What does this project do?
- **Tech stack** — Languages, frameworks, build tools, test frameworks, deployment targets.
- **Key workflows** — What does a developer typically do in this repo? (build, test, deploy, review, lint, migrate, etc.)
- **Existing commands** — Check if `.claude/commands/` already exists. If it does, read the existing commands so you don't duplicate them.

Present a brief summary to the user:

```
Repository: <name>
Tech stack: <summary>
Existing commands: <list or "None">
```

---

## Step 3: Ensure CLAUDE.md Exists

If `CLAUDE.md` does not exist in the repo root, create it first. Slash commands work best when the agent has project context.

**CLAUDE.md** should contain:
- Project overview and purpose
- Tech stack and key dependencies
- Build, test, and lint commands
- Code conventions and patterns
- Repo-specific constraints

If `CLAUDE.md` already exists, leave it as-is.

---

## Step 4: Generate Slash Commands

Create `.claude/commands/` (if it doesn't exist) and add 2–4 markdown command files tailored to this specific repository.

**Selection criteria** — Choose commands that match the repo's actual workflows. Common patterns:

| Repo type | Good commands |
|-----------|--------------|
| Web app | `/review`, `/test`, `/deploy`, `/docs` |
| API service | `/review`, `/test`, `/api-check`, `/migrate` |
| Library/package | `/review`, `/test`, `/docs`, `/release` |
| Data pipeline | `/review`, `/test`, `/validate`, `/docs` |
| Infrastructure | `/review`, `/plan`, `/deploy`, `/audit` |
| Monorepo | `/review`, `/test`, `/build`, `/docs` |

**Each command file** should contain:
- A clear one-line description at the top
- Step-by-step instructions for the agent
- Reference to relevant files, configs, or conventions
- Use `$ARGUMENTS` where the user might pass parameters

**Workflow parallelization** — Actively look for opportunities to design commands that exploit parallel execution:
- If a workflow has independent steps (e.g., lint + test + type-check), the command should instruct the agent to run them in parallel using concurrent tool calls or the Agent tool.
- If a command orchestrates work across multiple files or subsystems, design it to spawn parallel subagents for independent parts.
- Common parallelizable patterns: running tests across multiple packages, checking multiple services, validating independent concerns (types, lint, tests), building multiple targets.
- Include explicit `Launch these steps in parallel:` sections in the command file where appropriate.

**Do NOT create generic filler commands.** Every command should do something genuinely useful for this specific project. If only 2 commands make sense, create 2.

### Reviewing Existing Commands

If `.claude/commands/` already has commands, don't just skip them — **review and optimize**:
- Read each existing command file and evaluate its quality
- Check for missed parallelization opportunities (sequential steps that could run concurrently)
- Look for commands that are too generic and could be more tailored to the repo
- Identify missing commands that would fill workflow gaps
- Fix any commands that reference incorrect paths, tools, or conventions
- Report what was reviewed, what was improved, and what was added

---

## Step 5: Commit and Push

1. Stage the new command files (and CLAUDE.md if it was created).
2. Commit with the message: `Add Claude Code slash commands`
3. Push to the remote.

---

## Step 6: Summary

Print what was created:

```
Slash commands added to <repo-name>:

  /command-name — description
  /command-name — description
  ...

CLAUDE.md: <created / already existed>
```
