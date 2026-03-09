Scan, evaluate, and present repositories for user-approved retrofitting — then execute approved retrofits in parallel.

The user may provide the base path containing their repositories. For example: $ARGUMENTS

## Before Starting

1. Read `config.json` in this repository's root. If `repos_base_path` is set and the user didn't provide a path, use that stored path.
2. Read `scan-log.json` in this repository's root. This tracks which repos have already been visited. If it doesn't exist, create it with an empty `repos` object.
3. If this is the first run and `repos_base_path` is empty in `config.json`, save the provided path there.

---

## Phase 1: Scan & Evaluate

For each git repository under the base path, perform evaluation silently (do not ask the user anything yet). Record all findings for Phase 2.

### 1. Skip Already-Visited Repos

Check two signals:
1. `scan-log.json` — if an entry exists with `"status"` of `"skipped"` or `"not_suitable"`, skip silently. If status is `"retrofitted"`, include as a review candidate.
2. **README watermark** — if the repo's README contains the watermark but has no scan-log entry, include as a review candidate.

Evaluate repos with status `"error"`, `"retrofitted"` (for review), or repos not in the log.

### 2. Suitability Evaluation

For each candidate repo, read the README, examine the file structure, and assess:

- **Is it a real project?** Skip forks with no local changes, empty/abandoned repos, templates, mirrors.
- **Is it already scaffolded?** If it has CLAUDE.md, `.claude/commands/`, and `.claude/agents/` already populated, record as `"review_candidate"` — these repos can still benefit from review and optimization (parallelization improvements, quality fixes, gap filling).
- **Would scaffolding add value?** Very small repos (single-file scripts, dotfile collections, pure docs) may not benefit.

### 3. Record Evaluation Data

For each evaluated repo, record in a working data structure:

```json
{
  "repo_name": "example-repo",
  "path": "/home/user/repos/github/example-repo",
  "visibility": "public|private|unknown",
  "recommendation": "retrofit|not_suitable|already_complete",
  "reason": "Brief explanation of recommendation",
  "existing_scaffolding": {
    "has_claude_md": false,
    "has_commands": false,
    "has_agents": false
  },
  "tech_stack": "Brief tech stack summary"
}
```

Save this data to `working-data/interactive-<timestamp>.json`.

### 4. Show Scan Summary

After all repos are evaluated, print a summary table:

```
Scan complete: X repos found, Y candidates, Z skipped (already visited), W not suitable

Skipped repos (already processed): repo-a, repo-b, ...
Not suitable: repo-c (reason), repo-d (reason), ...
```

---

## Phase 2: User Review

Present each candidate repo (those with recommendation `"retrofit"` or `"review"`) to the user **one by one** for approval.

For each repo, show:

```
[N/M] repo-name (visibility | tech stack summary)
  Recommendation: retrofit / review & optimize
  Reason: <brief reason>
  Missing/Issues: CLAUDE.md, commands, agents  (or what needs review/improvement)

  Retrofit/review this repo? [y/n/q]
```

- **y** — mark for retrofit
- **n** — skip this repo
- **q** — quit review (skip all remaining)

Also offer batch shortcuts before starting the one-by-one review:
- **"all"** — approve all candidates
- **"none"** — skip all (end session)
- **"review"** — proceed with one-by-one review (default)

Record the user's decision for each repo. Save decisions to the same `working-data/interactive-<timestamp>.json` file, updating each entry with:

```json
{
  "user_decision": "approved|skipped|quit_remaining"
}
```

After review, show a confirmation summary:

```
Approved for retrofit: X repos
  - repo-1
  - repo-2
  ...

Skipped: Y repos

Proceed with retrofitting? [y/n]
```

---

## Phase 3: Execute Retrofits

For **public repos**, check `default_visibility_action` from `config.json`. If not set, ask the user once now (before spawning workers) and save their preference:
- `"open_source"` — commit all agent files
- `"gitignore"` — add agent files to `.gitignore`

Then spawn **parallel worker agents** for each approved repo. Each worker:

1. Runs `git pull` in the target repo.
2. Applies visibility handling based on the decided action.
3. Follows the full scaffolding process in `retrofit-repo.md` (guidance files, scaffold folders, slash commands, subagents, MCP evaluation). For repos in review mode, focuses on reviewing and optimizing existing scaffolding — checking for parallelization opportunities, quality improvements, and workflow gaps.
4. Saves the evaluation report to `working-data/reports/<repo-name>.md`.
5. Commits with message: `Add AI agent scaffolding (retrofitted)`
6. Pushes to remote.
7. Returns success or error status.

**Worker parallelism:** Launch workers using the Agent tool. Spawn up to 5 workers concurrently. As workers complete, launch the next batch until all approved repos are processed.

If any worker encounters an error, log the repo with status `"error"` and continue with the remaining repos.

---

## Phase 4: Wrap-Up

1. Update `scan-log.json` for every repo processed in this session:
   - Approved and successfully retrofitted → status `"retrofitted"`
   - Approved but errored → status `"error"` with error message
   - User skipped → status `"skipped"` with reason `"user_skipped_interactive"`
   - Not suitable → status `"not_suitable"` with reason
   - Reviewed and optimized → status `"reviewed_and_optimized"`
   - Reviewed, no changes needed → status `"already_optimized"`

2. Update `scan-log.json` with `last_run` timestamp.

3. Print final summary:
   - Total repos found
   - Evaluated this session
   - Approved by user
   - Successfully retrofitted
   - Skipped by user
   - Not suitable
   - Errors (list repo names and brief error)

4. Note that evaluation reports are in `working-data/reports/`.

---

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
