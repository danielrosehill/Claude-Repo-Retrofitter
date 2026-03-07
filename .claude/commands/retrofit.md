Retrofit one or more repositories with AI agent scaffolding.

The user will provide one or more absolute paths to target repositories. For example: $ARGUMENTS

## Before Starting

Read `config.json` in this repository's root for stored user preferences (base path, visibility defaults, repos to skip). Use these to avoid re-asking questions the user has already answered.

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

### 5. Add Scaffolding

Read and follow the instructions in `retrofit-repo.md` from this repository's root. Apply them to the **target repository**, not to this template repository.

### 6. Commit and Push

After completing all tasks for a repository:

1. Stage all new files (respect the `.gitignore` decisions from step 4).
2. Commit with the message: `Add AI agent scaffolding (retrofitted)`
3. If `auto_push` is true in `config.json`, push automatically. Otherwise ask the user.

### 7. Repeat

If multiple repository paths were provided, repeat steps 1-6 for each one. Report a summary at the end showing which repos were retrofitted and any that were skipped.
