Scan a directory of repositories and generate a report of missing AI agent scaffolding.

The user will provide the base path containing their repositories. For example: $ARGUMENTS

## Before Starting

1. Check `config.json` in this repository's root. If `repos_base_path` is set and the user didn't provide a path, use that stored path instead of asking.
2. Read `scan-log.json` for previously visited repos.

## Steps

1. Run the scan script against the provided path, saving output to `working-data/`:

```bash
./scan-repos.sh <path> ./working-data
```

2. Read the generated CSV file from `working-data/scan-<timestamp>.csv` and the `summary.md` report from the timestamped subdirectory. Present the results to the user.

3. Show the user the breakdown:
   - Repos missing all elements (best candidates for a full retrofit)
   - Repos partially scaffolded (may need selective updates)
   - Repos already fully scaffolded (no action needed)
   - Repos previously retrofitted (watermark detected in README) — these were processed by the retrofit agent and can be skipped
   - Repos already visited in previous runs (from `scan-log.json`) — show these separately so the user knows they can be skipped

4. Ask the user which repos they would like to retrofit. They can choose:
   - All repos missing all elements
   - A specific subset by name
   - Only repos missing specific elements (e.g. just slash commands)
   - Only repos not yet visited (exclude those in `scan-log.json`)

5. If this is the first run and `repos_base_path` is empty in `config.json`, save the provided path there for future sessions.

6. Once the user confirms their selection, run `/retrofit` with the chosen repository paths (constructed by joining the base path with each repo name).
