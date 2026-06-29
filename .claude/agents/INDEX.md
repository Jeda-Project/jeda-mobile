# Agents Index

> Invoke via the Agent tool or reference an agent name in a task.

---

## Jeda iOS-Specific (3)

| Agent | Model | When to Use |
|-------|-------|-------------|
| `jeda-ui-reviewer` | haiku | After modifying files in `Views/` — check SoC, JedaColor, HIG compliance, touch targets, SF Symbols |
| `jeda-security-guard` | haiku | Before commit — check API key exposure, Keychain vs UserDefaults, Firebase config, URL security |
| `jeda-a11y-guard` | — | Accessibility audit — VoiceOver labels, Dynamic Type, touch targets 44pt, reduce motion |

---

## Generic (8)

| Agent | Model | When to Use |
|-------|-------|-------------|
| `planner` | — | Before a new feature — PRD → architecture → task list → risk assessment |
| `architect` | opus | Architecture decisions — layer shape, coupling trade-offs, actor isolation violations |
| `code-reviewer` | sonnet | Quality/security/concurrency review. Run after writing or before committing. Verdict: APPROVE/WARNING/BLOCK |
| `tdd-guide` | — | Enforce RED→GREEN→REFACTOR with XCTest, mock via protocol, coverage target ≥80% |
| `performance-optimizer` | — | Core ML loading, SwiftUI re-render, memory management, networking efficiency |
| `build-error-resolver` | — | Diagnose Swift compiler errors, SPM issues, xcodebuild failures, Core ML compilation |
| `refactor-cleaner` | — | Unused imports, dead code, unused assets, duplicate logic across Views |
| `silent-failure-hunter` | — | Empty catch blocks, dangerous try?, Task without error handling, Firebase silent failures |

---

## Recommended Flows

- **New feature:** `planner` → implement → `jeda-ui-reviewer` → `jeda-security-guard` → `code-reviewer`
- **New view:** implement → `jeda-ui-reviewer` → `jeda-a11y-guard`
- **Build failure:** `build-error-resolver` with full error message
- **Suspicious code:** `silent-failure-hunter` — catches bugs that tests miss
- **Major architecture:** `architect` before implementation
