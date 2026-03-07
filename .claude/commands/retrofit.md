Retrofit one or more repositories with Claude scaffolding.

The user will provide one or more absolute paths to target repositories. For example: $ARGUMENTS

## For each target repository path:

### 1. Safety Pull

Navigate to the target repository and run `git pull` to ensure you are on the latest version before making any changes.

### 2. Verify No Code Changes Policy

You must NOT modify any existing source code, configuration files, or application logic. Your only job is to add Claude-specific scaffolding files and push the result.

### 3. Repository Visibility Check

Determine whether the repository is public or private:

```bash
gh repo view --json isPrivate --jq '.isPrivate'
```

- **If private**: All files can be committed freely.
- **If public**: Ask the user whether they want the Claude files (`.claude/`, `CLAUDE.md`, `AGENTS.md`) to be committed and open-sourced.
  - If the user **declines**, add the following to `.gitignore`:
    ```
    # Claude agent files (kept local for this public repo)
    .claude/
    CLAUDE.md
    AGENTS.md
    ```
  - The scaffold folders (`context-data/`, `planning/`, `pm/`, `from-ai/`, `user-docs/`) can still be committed as they are general-purpose.

### 4. Execute Task Files

Read and execute the task files from this repository in order:

1. `/home/daniel/repos/github/Claude-Repo-Retrofitter/tasks/1.md` - Create agent guidance files (CLAUDE.md, AGENTS.md)
2. `/home/daniel/repos/github/Claude-Repo-Retrofitter/tasks/2.md` - Create scaffold folders and consolidate
3. `/home/daniel/repos/github/Claude-Repo-Retrofitter/tasks/3.md` - Create slash commands
4. `/home/daniel/repos/github/Claude-Repo-Retrofitter/tasks/4.md` - Define subagents

Apply each task to the **target repository**, not to this template repository.

### 5. Commit and Push

After completing all tasks for a repository:

1. Stage all new files (respect the `.gitignore` decisions from step 3).
2. Commit with the message: `Add Claude agent scaffolding (retrofitted)`
3. Push to the remote.

### 6. Repeat

If multiple repository paths were provided, repeat steps 1-5 for each one.
