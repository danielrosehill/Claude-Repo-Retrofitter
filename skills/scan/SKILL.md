---
name: scan
description: Scan a directory of repositories and generate a report of missing AI agent scaffolding
---

Scan a directory of repositories and generate a report of missing AI agent scaffolding.

The user will provide the base path containing their repositories. For example: $ARGUMENTS

## Before Starting

1. Check if a `config.json` exists in the current working directory. If `repos_base_path` is set and the user didn't provide a path, use that stored path instead of asking.
2. Look for a `scan-log.json` file in the current working directory for previously visited repos.

## Steps

1. List all subdirectories under the provided path and check each one for:
   - Whether it's a git repository (has `.git/` directory)
   - Whether it has `CLAUDE.md`
   - Whether it has `.claude/commands/` with content
   - Whether it has `.claude/agents/` with content
   - Whether the README contains the watermark `*Repository evaluated by retrofit agent on ...*`
   - Visibility (public/private) via `gh repo view --json isPrivate --jq '.isPrivate'`

2. Categorize each repo and present the results:
   - Repos missing all elements (best candidates for a full retrofit)
   - Repos partially scaffolded (may need selective updates)
   - Repos already fully scaffolded (no action needed)
   - Repos previously retrofitted (watermark detected in README) — these were processed by the retrofit agent and can be skipped
   - Repos already visited in previous runs (from `scan-log.json`) — show these separately so the user knows they can be skipped

3. Ask the user which repos they would like to retrofit. They can choose:
   - All repos missing all elements
   - A specific subset by name
   - Only repos missing specific elements (e.g. just slash commands)
   - Only repos not yet visited (exclude those in `scan-log.json`)

4. If this is the first run and `repos_base_path` is empty in `config.json`, save the provided path there for future sessions. Create `config.json` if it doesn't exist.

5. Once the user confirms their selection, run `/repo-retrofitter:retrofit` with the chosen repository paths (constructed by joining the base path with each repo name).
