# Session Log — 2026-06-28 — claude-config-setup

## Branch
`main` — untracked files, belum di-commit

## Tujuan Sesi
Setup lengkap konfigurasi Claude Code untuk project Jeda iOS dari nol.
Referensi: `code-sheesh` (website) dan `jeda-backend` (mobile backend).

## Yang Dikerjakan

### Root Documentation
- `CLAUDE.md` — Behavioral protocol: RTK enforcement, urutan baca sebelum mulai, MCP servers, commit format, naming conventions, larangan keras
- `AGENTS.md` — 15 Golden Rules iOS: layer ownership (Rules 1–4), dependency injection (5–6), concurrency/actor (7–8), styling/design system (9–11), networking (12–13), code quality (14–15)
- `PRODUCT.md` — Konteks produk Jeda: target user, brand personality (tenang, hangat, jujur, cerdas), design philosophy (calm/muted palette), fitur yang ada vs direncanakan
- `SSOT.md` — Tech stack, layer ownership map, design tokens (JedaColor + JedaSpacing), ADR-001 s/d ADR-005, environment variables, CI/CD

### MCP Configuration
- `.mcp.json` — 4 MCP servers:
  - `serena-jeda-mobile`: Serena untuk iOS project (--project .)
  - `serena-jeda-backend`: Serena untuk backend project (absolute path)
  - `github`: GitHub MCP via GITHUB_PERSONAL_ACCESS_TOKEN
  - `context7`: Library documentation lookup

### Claude Settings
- `.claude/settings.json` — Permissions (allow xcodebuild, swift, swiftlint, git, gh, rtk; deny rm -rf, push main, edit pbxproj/plist/SSOT/AGENTS) + hooks config

### Hooks (6 shell scripts)
- `safety-check.sh` — PreToolUse/Bash: blokir rm -rf, git push main, edit pbxproj
- `generated-guard.sh` — PreToolUse/Write: blokir edit file generated/protected
- `token-guard.sh` — PreToolUse/Write: warn Color(hex:), .system(size:), force unwrap
- `swift-lint.sh` — PostToolUse/Write: jalankan SwiftLint jika tersedia
- `notify.sh` — Notification: macOS desktop notification
- `stop-check.sh` — Stop: session summary + pre-commit checklist

### Agents (12 files)
- `jeda-ui-reviewer` (haiku): SoC, JedaColor, HIG, a11y, SF Symbols di Views/
- `jeda-security-guard` (haiku): API key, Keychain vs UserDefaults, Firebase, SSL
- `jeda-a11y-guard`: VoiceOver, Dynamic Type, touch targets, reduce motion
- `planner`: PRD → arsitektur → task list → risk assessment
- `architect` (opus): Read-only, God Object detection, coupling, actor isolation
- `code-reviewer` (sonnet): SOLID, concurrency, Sendable, memory — verdict APPROVE/WARNING/BLOCK
- `tdd-guide`: XCTest RED→GREEN→REFACTOR, mock via protocol, ≥80% coverage
- `performance-optimizer`: Core ML lazy load, SwiftUI re-render, memory, debounce
- `build-error-resolver`: Swift compiler, SPM, xcodebuild, Core ML errors
- `refactor-cleaner`: Unused imports, dead code, duplicate logic
- `silent-failure-hunter`: Empty catch, try?, Task tanpa error handling
- `INDEX.md`: Tabel semua agents + recommended flows

### Commands (13 files)
- `/plan`, `/review`, `/check-fix`, `/commit`, `/create-pr`
- `/checkpoint`, `/checkpoint-summary`, `/aside`
- `/a11y-audit`, `/build-sim`, `/test`
- `/merge-pr`, `/resolve-pr-review`
- `INDEX.md`: Tabel semua commands per kategori

### Anti-Patterns (3 files)
- `swiftui-task-vs-onappear.md`: .task untuk async (auto-cancel), .onAppear untuk sync saja
- `actor-isolation-pitfalls.md`: @MainActor terlalu luas, nonisolated salah tempat, akses actor dari View
- `coreml-model-loading.md`: Jangan load di main thread, bundle path yang benar, MLModelConfiguration optimal

### Rules (11 files)
```
rules/
├── common/ — coding-style, git-workflow, security, testing, development-workflow
├── swift/  — coding-style, patterns, concurrency
├── swiftui/ — coding-style, patterns
└── ios/    — design-quality, performance, accessibility
```

## Keputusan Arsitektur Config

1. **Kategori rules**: Menggunakan `swift/`, `swiftui/`, `ios/` (bukan `react/typescript/web/` dari code-sheesh)
2. **Serena dual instance**: `serena-jeda-mobile` untuk iOS project, `serena-jeda-backend` untuk backend — sama dengan pola `web-siera` yang punya `serena-api` + `serena-web`
3. **settings.json linter update**: Format hooks diupdate ke `{ type, command }` nested — format baru yang lebih clean
4. **Tidak ada `impeccable` plugin**: Jeda iOS tidak butuh web design skill ini

## Langkah Selanjutnya

```bash
git add -A
git commit -m "chore(config): setup claude code configuration for jeda-mobile"
```

Setelah commit, mulai development fitur dengan `/plan <nama fitur>`.
