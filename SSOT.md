# SSOT.md — Single Source of Truth — Jeda iOS

> This document is the primary architecture reference. Must not be changed by Claude.

---

## Tech Stack

| Component | Technology | Version |
|---|---|---|
| Framework | SwiftUI | iOS 17.6+ |
| Language | Swift | 5.0 |
| Build Tool | Xcode | 26.4.1 |
| Dependency Manager | Swift Package Manager (SPM) | Native |
| ML Framework | Core ML | on-device |
| ML Model | IndoBERT-int8 | fine-tuned for emotion classification |
| Analytics | Firebase Analytics | 12.15.0+ |
| Networking | URLSession + async/await | Native |
| Architecture | Clean Architecture + MVVM hybrid | — |

---

## Layer Ownership Map

```
Jeda/App/           → @main, AppDelegate, root view, environment setup
Jeda/Models/        → Domain types, enums, protocols (ZERO dependencies)
Jeda/Services/      → Business logic, ML inference, HTTP networking
  └─ Networking/    → APIService, APIEndpoint protocol, APIError, builders
     └─ Endpoints/  → Feature-specific endpoint definitions
Jeda/Views/         → SwiftUI screens and reusable components
  └─ Reusable Views/ → Shared UI components (JedaButton, JedaChart, etc.)
Jeda/Resources/     → Assets.xcassets, Core ML model, tokenizer vocab
skills/jeda-ios/    → Claude Code skill reference (SKILL.md, reference.md)
.claude/            → Claude Code configuration (agents, commands, hooks)
.github/workflows/  → CI/CD pipelines
```

---

## Design Tokens

### Colors (defined in `Jeda/Views/Reusable Views/JedaTheme.swift`)

```swift
// Calm/Muted Palette
enum JedaColor {
  case sageGreen    // #7A8B7F — balance, primary element
  case dustyBlue    // #8FA3AD — calm, info
  case warmClay     // #C49A7C — warmth, accent
  case terracotta   // #B8654F — warm alert, energy

  // Semantic
  case textPrimary    // primary text
  case textSecondary  // secondary text/subtitle
  case background     // main background
  case surface        // card/surface
  case border         // dividing line
}
```

> **REQUIRED:** Always use the `JedaColor` enum. No `Color(hex:)` or hardcoded `.green`, `.blue`, etc. outside JedaTheme.swift.

### Spacing (in `JedaTheme.swift`)

```swift
enum JedaSpacing {
  static let xs: CGFloat = 4
  static let sm: CGFloat = 8
  static let md: CGFloat = 16
  static let lg: CGFloat = 24
  static let xl: CGFloat = 32
  static let xxl: CGFloat = 48
}
```

### Typography

Use `.font(.body)`, `.font(.headline)`, etc. — **not** `.font(.system(size: N))`. Dynamic Type must always work.

---

## Architecture Decisions

### ADR-001: Actor for Core ML Service
`EmotionClassificationService` is an `actor` to ensure model loading and inference happen isolated from the main thread. This prevents UI freezes and race conditions on model state.

### ADR-002: Protocol-Oriented Services
All services expose a protocol (`EmotionAnalyzing`, etc.). Views depend on the protocol via `@Environment`. This enables mock injection in previews and unit tests.

### ADR-003: On-Device Only ML
The `JedaEmotionIndoBERT-int8.mlpackage` model runs entirely on-device. No user text is sent to a server for inference. This is a privacy guarantee that must not be violated.

### ADR-004: SwiftUI Form for Input
Use native SwiftUI `Form`, `List`, `Section` for data-heavy layouts. Avoid custom containers that fight with HIG.

### ADR-005: Networking Ready, Not Yet Connected
The networking layer (`APIService`, `APIEndpoint`, `APIConfiguration`) is already built for future backend integration. Currently emotion classification is entirely local. No production backend URL is needed until the backend is available.

---

## Environment Variables

| Variable | Location | Notes |
|---|---|---|
| `GITHUB_PERSONAL_ACCESS_TOKEN_JEDA` | shell env | For GitHub CLI (dev only) |
| Firebase config | `GoogleService-Info.plist` | **Do not commit the production key** |
| Backend API base URL | `APIConfiguration.swift` | Changes per environment (dev/staging/prod) |

---

## CI/CD

| Workflow | Trigger | Action |
|---|---|---|
| `ios-ci.yml` | PR/push to develop | Build + test on simulator |
| `ios-ci-develop.yml` | Push to develop | Quality gate |
| `ios-cd-main.yml` | Push to main | Upload to TestFlight |

**Standard build command:**
```bash
xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  | xcpretty
```

---

## Files That Must Not Be Edited Manually

- `Jeda.xcodeproj/project.pbxproj` — Managed by Xcode
- `Jeda/Resources/GoogleService-Info.plist` — Firebase config, sensitive
- `Jeda/Resources/Models/JedaEmotionIndoBERT-int8.mlpackage/` — Binary ML model
- `SSOT.md`, `AGENTS.md` — Only developers may modify these
