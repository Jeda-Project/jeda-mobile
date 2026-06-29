# /aside — Quick Side Task

Pause the current task, complete a question or small fix, then return.

## Steps

1. **Run `/checkpoint` first** — create a safety commit + session log so nothing is lost when context is compressed
2. Complete the aside (keep it small — if this is a new feature, open a separate branch)
3. Run the quality gate if any code was changed: `rtk xcodebuild build -project Jeda.xcodeproj -scheme Jeda -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -quiet`
4. **Return** — restate the paused task from the template below and continue

## Notes

- An aside should take at most ~15 minutes. If it is larger, create a new task/branch.
- Do not mix aside changes with the feature being worked on in the same commit

## Template

```
## Aside: <what>

### Current task (paused)
- File: <path>
- Status: <where we left off>

### Aside task
<description>

### Return to
<resume point>
```
