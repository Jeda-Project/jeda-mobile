# /checkpoint [desc] — Safety Commit

Create a safety commit with a timestamp to save current progress.

## Usage
```
/checkpoint before refactor emotion service
/checkpoint UI draft mood picker
```

## Steps

1. Stage all changes: `git add -A`
2. Create the commit:
```bash
git commit -m "chore: checkpoint — <desc> [<ISO timestamp>]"
```

Example: `chore: checkpoint — before refactor emotion service [2026-06-28T10:30:00]`

## Notes

- Checkpoint commits do not need to pass the full quality gate
- Use before large refactors or experiments
- Can be undone with `git reset HEAD~1` if needed
