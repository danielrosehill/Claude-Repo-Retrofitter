Scan a directory of repositories and generate a report of missing Claude scaffolding.

The user will provide the base path containing their repositories. For example: $ARGUMENTS

## Steps

1. Run the scan script against the provided path, saving output to `working-data/`:

```bash
./scan-repos.sh <path> ./working-data
```

2. Read the generated CSV file from `working-data/scan-<timestamp>.csv` and the `summary.md` report from the timestamped subdirectory. Present the results to the user.

3. Show the user the breakdown:
   - Repos missing all Claude elements (best candidates for a full retrofit)
   - Repos partially scaffolded (may need selective updates)
   - Repos already fully scaffolded (no action needed)

4. Ask the user which repos they would like to retrofit. They can choose:
   - All repos missing all elements
   - A specific subset by name
   - Only repos missing specific elements (e.g. just slash commands)

5. Once the user confirms their selection, run `/retrofit` with the chosen repository paths (constructed by joining the base path with each repo name).
