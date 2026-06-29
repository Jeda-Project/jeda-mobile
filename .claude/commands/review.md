# /review — Senior iOS Code Review

Perform a thorough code review on staged changes or the specified files.

## Steps

1. **Check staged diff**: `git diff --cached`
2. **Build check**: ensure the project still builds
3. **Use the `code-reviewer` agent** to review:
   - AGENTS.md compliance (15 Golden Rules)
   - SoC violations (business logic in View, SwiftUI in Service)
   - Swift concurrency correctness
   - Memory management
   - Accessibility
   - Error handling
4. **Use the `jeda-ui-reviewer` agent** if there are changes in `Views/`
5. **Use the `jeda-security-guard` agent** if there are changes in Services or config

## Output

Structured report with verdict: **APPROVE / WARNING / BLOCK**

If BLOCK, explain what must be fixed before committing.
