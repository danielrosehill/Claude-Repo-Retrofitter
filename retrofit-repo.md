Your task is to update a repository created by the user in order to add several files which are intended to streamline the repository structure for use with an AI agent.

## Important Constraints

- **No code changes.** You must not modify any existing source code, configuration files, or application logic in the target repository. Your only purpose is to add Claude-specific scaffolding files (CLAUDE.md, AGENTS.md, folder structure, slash commands, subagents) and push them back up.
- **Safety pull.** Before making any changes, always run `git pull` in the target repository to ensure you are working on the latest version and avoid conflicts.

## Repository Visibility Check

Before committing, determine whether the target repository is **public** or **private**:

1. Check using: `gh repo view --json isPrivate --jq '.isPrivate'` (run from within the target repo).
2. **If private**: Proceed normally. All files can be committed, including `.claude/` contents (agents, slash commands).
3. **If public**: Ask the user whether they want the Claude-specific files (`.claude/agents/`, `.claude/commands/`, `CLAUDE.md`, `AGENTS.md`) to be committed and open-sourced. If the user declines:
   - Add `.claude/` to `.gitignore`
   - Add `CLAUDE.md` and `AGENTS.md` to `.gitignore`
   - The scaffold folders (`context-data/`, `planning/`, `pm/`, `from-ai/`, `user-docs/`) can still be committed as they are general-purpose.

## Execution

Work through the task files in `tasks/` in numerical order (1.md, 2.md, 3.md, 4.md). Each task file contains specific instructions for one phase of the retrofit.
