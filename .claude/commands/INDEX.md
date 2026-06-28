# Commands Index

> Invoke dengan `/command-name` di Claude Code CLI.

---

## Planning

| Command | Kapan Digunakan |
|---------|----------------|
| `/plan` | Sebelum fitur baru — breakdown per layer (Models → Services → Views), risk assessment |

---

## Code Review

| Command | Kapan Digunakan |
|---------|----------------|
| `/review` | Review menyeluruh staged changes (SoC, AGENTS.md compliance, a11y, Swift best practices) |
| `/a11y-audit [path]` | Audit aksesibilitas SwiftUI — VoiceOver, Dynamic Type, touch targets |

---

## Quality Gates

| Command | Kapan Digunakan |
|---------|----------------|
| `/check-fix` | Build + SwiftLint; auto-fix yang bisa di-fix, report PASS/FAIL |
| `/build-sim` | Build ke iPhone 16 Simulator, tampilkan hasil bersih |
| `/test` | Jalankan XCTest suite, report test count + failures |

---

## Git & Release

| Command | Kapan Digunakan |
|---------|----------------|
| `/commit` | Quality gate → inspect diff → draft conventional commit message |
| `/create-pr` | Buat PR dari branch saat ini dengan body yang terstandarisasi |
| `/merge-pr` | Merge PR yang sudah diapprove via GitHub MCP |
| `/resolve-pr-review` | Tangani dan respond ke review comments |

---

## Session Management

| Command | Kapan Digunakan |
|---------|----------------|
| `/checkpoint [desc]` | Safety commit mid-session dengan timestamp |
| `/checkpoint-summary [domain]` | Session summary untuk handover — simpan ke session-logs/ |
| `/aside` | Pause task saat ini, handle quick side fix, lalu kembali |
