# Agents Index

> Invoke via Agent tool atau referensikan nama agent dalam task.

---

## Jeda iOS-Specific (3)

| Agent | Model | Kapan Digunakan |
|-------|-------|----------------|
| `jeda-ui-reviewer` | haiku | Setelah modifikasi file di `Views/` — cek SoC, JedaColor, HIG compliance, touch targets, SF Symbols |
| `jeda-security-guard` | haiku | Sebelum commit — cek API key exposure, Keychain vs UserDefaults, Firebase config, URL security |
| `jeda-a11y-guard` | — | Audit aksesibilitas — VoiceOver labels, Dynamic Type, touch targets 44pt, reduce motion |

---

## Generic (8)

| Agent | Model | Kapan Digunakan |
|-------|-------|----------------|
| `planner` | — | Sebelum fitur baru — PRD → arsitektur → task list → risk assessment |
| `architect` | opus | Keputusan arsitektur — layer shape, coupling trade-offs, actor isolation violations |
| `code-reviewer` | sonnet | Quality/security/concurrency review. Jalankan setelah menulis atau sebelum commit. Verdict: APPROVE/WARNING/BLOCK |
| `tdd-guide` | — | Enforce RED→GREEN→REFACTOR dengan XCTest, mock via protocol, coverage target ≥80% |
| `performance-optimizer` | — | Core ML loading, SwiftUI re-render, memory management, networking efficiency |
| `build-error-resolver` | — | Diagnosa Swift compiler errors, SPM issues, xcodebuild failures, Core ML compilation |
| `refactor-cleaner` | — | Unused imports, dead code, unused assets, duplicate logic antar Views |
| `silent-failure-hunter` | — | Empty catch blocks, try? berbahaya, Task tanpa error handling, Firebase silent failures |

---

## Recommended Flows

- **Fitur baru:** `planner` → implement → `jeda-ui-reviewer` → `jeda-security-guard` → `code-reviewer`
- **View baru:** implement → `jeda-ui-reviewer` → `jeda-a11y-guard`
- **Build failure:** `build-error-resolver` dengan error message lengkap
- **Suspicious code:** `silent-failure-hunter` — menangkap bug yang test miss
- **Arsitektur besar:** `architect` dulu sebelum implementasi
