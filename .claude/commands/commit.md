# /commit — Conventional Commit with Quality Gate

Draft a correct commit message after the quality gate passes. Does NOT execute the commit.

## Steps

1. **Quality gate**:
   - Build succeeded? (`rtk xcodebuild build ...`)
   - SwiftLint clean? (`rtk swiftlint lint --quiet`)

2. **Inspect staged diff**: `git diff --cached`

3. **Draft commit message** with format:
```
type(scope): subject — max 50 characters

Optional body (WHY, not WHAT)
```

   **Types:** `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `perf`, `test`
   **Scopes:** `views`, `services`, `models`, `ml`, `networking`, `a11y`, `config`

4. **Display for review** — DO NOT execute `git commit` without user confirmation.

## Example Output

```
Proposed commit:

feat(ml): add confidence threshold filter to emotion classifier

Classifier now returns nil for predictions below 0.6 confidence
to prevent misleading low-confidence results being shown to users.

---
Run: git commit -m "..." to execute
```
