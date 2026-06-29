# Development Workflow

## Checklist Before Starting a Task

1. Call `mcp__serena-jeda-mobile__initial_instructions`
2. Read `AGENTS.md` and `SSOT.md`
3. Understand the scope of the task — ask if anything is unclear
4. Look for existing patterns before creating new ones
5. Use Context7 to look up unfamiliar APIs

## Checklist Before Committing

- [ ] Build succeeded: `rtk xcodebuild build -project Jeda.xcodeproj -scheme Jeda -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
- [ ] SwiftLint clean: `rtk swiftlint lint --quiet` (if available)
- [ ] No SwiftUI import in the Services layer
- [ ] No hardcoded hex colors
- [ ] All interactive elements have an `accessibilityLabel`
- [ ] No new force unwraps in production code
- [ ] Relevant tests pass
- [ ] Commit message follows the conventional format

## Self-Review Gate (Rule 15 from AGENTS.md)

Before declaring a task done, Claude MUST:
1. Re-read the changes made
2. Run a build check
3. Verify no Golden Rules were violated
4. Ensure errors are not swallowed

## RTK Usage

**ALL** terminal commands must use the `rtk` prefix:
```bash
rtk xcodebuild build ...
rtk swiftlint lint ...
rtk swift test
rtk git status
```

## New Feature Workflow

```
1. /plan <feature name>          → Create plan, wait for confirmation
2. Implement per layer:
   Models → Services → Views
3. /check-fix                    → Ensure build & lint are clean
4. /review                       → Code review
5. /commit                       → Draft commit message
6. git commit -m "..."           → Execute commit
7. /create-pr                    → Create PR to main
```
