Autonomously scan, evaluate, and retrofit repositories with AI agent scaffolding — no user interaction required.

The user may provide the base path containing their repositories. For example: $ARGUMENTS

## Before Starting

1. Read `config.json` in this repository's root. If `repos_base_path` is set and the user didn't provide a path, use that stored path.
2. Read `scan-log.json` in this repository's root. This tracks which repos have already been visited. If it doesn't exist, create it with an empty `repos` object.
3. If this is the first run and `repos_base_path` is empty in `config.json`, save the provided path there.

## For each git repository under the base path:

### 1. Skip Already-Visited Repos

Check two signals:
1. `scan-log.json` — if an entry exists with `"status"` of `"skipped"` or `"not_suitable"`, skip silently. If status is `"retrofitted"`, proceed in **review and optimize mode** to check for improvements.
2. **README watermark** — if the repo's README contains the line `*Repository evaluated by retrofit agent on ...*` but has no scan-log entry, add it in review mode rather than skipping.

Re-process repos with status `"error"`, `"retrofitted"` (for review), or repos not in the log.

### 2. Suitability Evaluation

Before retrofitting, evaluate whether the repo is a good candidate for agent scaffolding. Read the repo's README, look at its file structure, and consider:

- **Is it a real project?** Skip repos that are just forks with no local changes, empty/abandoned repos with no meaningful content, template repos, or mirror-only repos.
- **Is it already scaffolded?** If it has CLAUDE.md, `.claude/commands/`, and `.claude/agents/` already populated, switch to **review and optimize mode** — review existing commands and agents for missed parallelization opportunities, overly generic instructions, incorrect references, and workflow gaps. Improve what's there rather than skipping. Log as `"reviewed_and_optimized"` if changes were made, or `"already_optimized"` if no improvements were needed.
- **Would scaffolding add value?** Very small repos (single-file scripts, dotfile collections, pure documentation repos with no code) may not benefit from full scaffolding. Use judgment — if the repo has any meaningful code, it's worth scaffolding.

If the repo is NOT suitable, log it in `scan-log.json` with status `"not_suitable"` and a brief reason, then move on.

### 3. Retrofit

If the repo IS suitable:

1. Run `git pull` in the target repo.
2. Determine visibility (`gh repo view --json isPrivate --jq '.isPrivate'`).
3. For public repos, use `default_visibility_action` from `config.json`. If not set, default to `"open_source"` in autonomous mode (since there's no user to ask).
4. Follow the full scaffolding process in `retrofit-repo.md` (guidance files, scaffold folders, slash commands, subagents, MCP evaluation).
5. Save the evaluation report to `working-data/reports/<repo-name>.md`.
6. Commit with message: `Add AI agent scaffolding (retrofitted)`
7. Push to remote.
8. Log in `scan-log.json` with status `"retrofitted"`.

If any error occurs during retrofit, log the repo with status `"error"` and the error message, then continue to the next repo.

## scan-log.json Format

```json
{
  "last_run": "2026-03-08T12:00:00Z",
  "repos_base_path": "/home/user/repos/github",
  "repos": {
    "repo-name": {
      "status": "retrofitted|skipped|not_suitable|error|already_optimized|reviewed_and_optimized",
      "reason": "optional reason for skip/not_suitable/error",
      "timestamp": "2026-03-08T12:00:00Z",
      "visibility": "public|private|unknown"
    }
  }
}
```

## After All Repos Are Processed

1. Update `scan-log.json` with `last_run` timestamp.
2. Print a summary:
   - Total repos found
   - Newly retrofitted
   - Skipped (already visited)
   - Not suitable (with reasons)
   - Errors
3. Note that evaluation reports are in `working-data/reports/`.
