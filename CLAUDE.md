# CLAUDE.md — Jeda iOS

## Project Identity

Jeda is an iOS mental health journaling app with AI-based emotion classification (on-device, IndoBERT + Core ML). Target users: young Indonesian adults who want to understand their emotional patterns.

## RTK Enforcement

**ALL** terminal commands MUST use the `rtk` prefix:

```bash
# ✅ Correct
rtk xcodebuild build -project Jeda.xcodeproj -scheme Jeda -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
rtk swift test

# ❌ Forbidden
xcodebuild build ...
swift test
```

> Exception: commands inside hook shell scripts may run directly without `rtk`.

## Read & Setup Order Before Starting

Before working on any task, follow these steps in order:

1. Call `mcp__serena-jeda-mobile__initial_instructions` — **REQUIRED** before touching any Swift file
2. Read `AGENTS.md` — Golden Rules (must be followed without exception)
3. Read `SSOT.md` — Architecture, design tokens, environment variables
4. Read `PRODUCT.md` — Product context and design philosophy
5. Read `skills/jeda-ios/SKILL.md` — Jeda-specific iOS code patterns

## MCP Servers

### Serena (`serena-jeda-mobile` / `serena-jeda-backend`)
- **REQUIRED** to call `mcp__serena-jeda-mobile__initial_instructions` at the start of every session
- Use Serena for all operations on `.swift` files: find symbol, rename, safe delete, get diagnostics
- Use `serena-jeda-backend` when working on a task that also touches the backend project
- **DO NOT** use built-in Read/Write for Swift files when Serena is available — Serena is more accurate

### Context7
- Use `mcp__context7__resolve-library-id` + `mcp__context7__query-docs` before implementing a new API
- Required for: unfamiliar SwiftUI APIs, Core ML API, Firebase SDK, URLSession patterns
- More accurate than training knowledge for fast-changing APIs

### GitHub MCP
- Use for PR and issue management operations
- Already covered via the `GH_TOKEN` environment variable

## Architecture Overview

```
Views/          → SwiftUI only. No business logic allowed.
Services/       → Business logic, ML, networking. No SwiftUI import.
Models/         → Pure types, enums, protocols. No logic.
Resources/      → Assets, Core ML model, tokenizer. No Swift logic.
App/            → Entry point & root view setup only.
```

## Build Commands

```bash
# Build to simulator
rtk xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run tests
rtk xcodebuild test \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# SwiftLint (if available)
rtk swiftlint lint --quiet
```

## Commit Format

```
type(scope): subject — max 50 characters

Optional body: explain the context/reason (WHY, not WHAT)
```

**Types:** `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `perf`, `test`

**Scope examples:** `views`, `services`, `models`, `ml`, `networking`, `a11y`

**Examples:**
```
feat(ml): integrate IndoBERT emotion classifier via Core ML
fix(views): correct touch target size on MoodPicker to 44pt
refactor(services): extract tokenizer into dedicated actor
```

## Naming Conventions

- **Views:** `Jeda<Name>View.swift` (screen) or `Jeda<Name>.swift` (component)
- **Services:** `<Name>Service.swift`
- **Models:** Singular noun (`Emotion.swift`, `JournalEntry.swift`)
- **ViewModels:** `<Name>ViewModel.swift` (when needed)
- **Protocols:** Name ending in `-ing` or `-able` (`EmotionAnalyzing`, `Persistable`)

## Context Loading Strategy

Read the relevant section before starting a task:

| Task | Read |
| --- | --- |
| New SwiftUI View | SSOT.md §Design Tokens + `rules/swiftui/patterns.md` |
| Service / business logic | SSOT.md §Architecture + `rules/swift/patterns.md` |
| Core ML / emotion classifier | SSOT.md §ML + `anti-patterns/coreml-model-loading.md` |
| Networking / new endpoint | AGENTS.md §Networking + `rules/common/security.md` |
| Accessibility | AGENTS.md §HIG + `rules/ios/design-quality.md` |
| Security / secrets / Keychain | `rules/common/security.md` + `anti-patterns/keychain-vs-userdefaults.md` |
| Testing | `rules/common/testing.md` |
| Comments / style | `rules/common/comments.md` |
| Dependency injection | `anti-patterns/environment-injection.md` |
| swiftformat + SwiftLint conflict | `anti-patterns/swiftformat-swiftlint-conflict.md` |

## Code Comments

Full rules: [`rules/common/comments.md`](.claude/rules/common/comments.md)

Summary: every `.swift` file must begin with the following docblock, **before** any imports:

```swift
/**
 * Scope: FileName.swift
 * Purpose: one sentence describing what this file does.
 */
```

No inline `//` comments. `*View.swift` files must have zero comments.

## Hard Restrictions

- ❌ Do not use `force unwrap` (`!`) except in tests or IBOutlet
- ❌ Do not hardcode colors — always use `JedaColor` from `JedaTheme.swift`
- ❌ Do not import SwiftUI in the Services layer
- ❌ Do not access `EmotionClassificationService.shared` directly from a View — use `@Environment`
- ❌ Do not load the Core ML model on the main thread
- ❌ Do not manually edit `Jeda.xcodeproj/project.pbxproj`
- ❌ Do not store secrets in UserDefaults — use Keychain
- ❌ Do not use a hardcoded API URL string — use `APIConfiguration`

## Formatting & Linting

Two tools with separate responsibilities — **must not overlap**:

| Tool | Responsibility | Not used for |
|------|---------------|---------------------|
| **SwiftFormat** | Indentation, spacing, brace, import sorting, trailing comma | Logic/quality rules |
| **SwiftLint** | Code quality, force unwrap, complexity, custom rules | Formatting (do not use `--fix`) |

### Workflow before commit
```bash
# 1. Format first (SwiftFormat)
swiftformat .

# 2. Lint only — without --fix (SwiftFormat already handles formatting)
rtk swiftlint lint --quiet
```

### Xcode Build Phase (add manually in Xcode)
In Xcode → Jeda target → Build Phases → `+` → New Run Script Phase, add:
```bash
if which swiftformat > /dev/null; then
    swiftformat --config "${SRCROOT}/.swiftformat" "${SRCROOT}/Jeda"
fi
```
Uncheck: **Based on dependency analysis** = OFF (run every build)
