# Jeda — Mental Health Journaling for iOS

Jeda is an iOS journaling app that helps users understand their emotional patterns through writing. The name *Jeda* (Indonesian: "pause" or "break") reflects the product philosophy: giving users a moment of intentional reflection amidst daily life.

Emotion classification runs entirely **on-device** using a fine-tuned IndoBERT model via Core ML — no journal text is ever sent to a server.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [AI Models](#ai-models)
- [Project Structure](#project-structure)
- [Design System](#design-system)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [CI/CD](#cicd)
- [Privacy](#privacy)
- [Contributing](#contributing)

---

## Features

### Live
- **On-Device Emotion Classification** — Write a journal entry; IndoBERT classifies the dominant emotion (happy, sadness, anger, fear, love) with a confidence score. All inference happens locally via Core ML.
- **Reflection Flow** — Full compose → save → list flow for reflection entries with deeper reflection prompts.
- **Emotion History** — Weekly overview of emotional patterns, daily entries, and AI-generated weekly summaries.
- **Crisis Safety Net** — Automatic detection of crisis-related content with `JedaSafetyBanner` and `JedaCrisisSupportSheet`.
- **Onboarding** — First-launch onboarding flow with AI consent gate for optional cloud features.
- **Design System** — Full component library: `JedaButtons`, `JedaCharts`, `JedaGlassSurface`, `JedaMoodPicker`, `JedaReflectionCard`, `JedaStateViews`, `JedaWeeklyPatternCard`, and more.

### Planned
- Weekly and monthly emotion trend reports
- Emotion-based reflection prompts
- Backend API integration (infrastructure already in place)
- TestFlight distribution via CD pipeline

---

## Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| UI Framework | SwiftUI | iOS 17.6+ |
| Language | Swift | 5.0 |
| Build Tool | Xcode | 16.4.1 |
| Dependency Manager | Swift Package Manager | Native |
| ML Framework | Core ML | On-device |
| ML Model | IndoBERT-int8 | Fine-tuned for emotion classification |
| AI Provider | OpenRouter | `nvidia/nemotron-3-ultra-550b-a55b:free`, `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free` |
| Analytics | Firebase Analytics | 12.15.0+ |
| Networking | URLSession + async/await | Native |
| Architecture | Clean Architecture + MVVM hybrid | — |
| Linting | SwiftLint | — |
| Formatting | SwiftFormat | 0.61.1 |

---

## Architecture

Jeda follows a **Clean Architecture + MVVM hybrid** pattern with strict layer ownership. Each layer has a clearly defined responsibility and a hard boundary on what it can import or do.

```
┌─────────────────────────────────────┐
│              Views/                 │  SwiftUI only. No business logic.
│         (SwiftUI Screens)           │  Reads from @Environment / @StateObject.
└────────────────┬────────────────────┘
                 │ @StateObject / @ObservedObject
┌────────────────▼────────────────────┐
│           ViewModels/                │  Presentation state & orchestration.
│      (ObservableObject classes)      │  No SwiftUI import beyond Combine/Observation.
└────────────────┬────────────────────┘
                 │ @Environment injection
┌────────────────▼────────────────────┐
│            Services/                │  Business logic, ML inference,
│    (Actors, Classes, Structs)       │  networking, persistence.
│                                     │  No SwiftUI import.
└────────────────┬────────────────────┘
                 │ Pure types only
┌────────────────▼────────────────────┐
│             Models/                 │  Domain types, enums, protocols.
│       (Structs, Enums)              │  Zero dependencies. No async.
└─────────────────────────────────────┘
```

### Key Architectural Decisions

**ADR-001 — Actor for Core ML Service**
`EmotionClassificationService` is an `actor`, ensuring model loading and inference are isolated from the main thread. This prevents UI freezes and eliminates race conditions on model state.

**ADR-002 — Protocol-Oriented Services**
Every service exposes a protocol (e.g. `EmotionAnalyzing`). Views depend on the protocol via `@Environment`, never the concrete type. This enables mock injection in previews and unit tests.

**ADR-003 — On-Device Only ML**
`JedaEmotionIndoBERT-int8.mlpackage` runs fully on-device. No user text is sent to a server for inference. This is a non-negotiable privacy guarantee.

**ADR-004 — Environment Injection over Singletons**
Services are injected at the app root via `@Environment`. Views never call `SomeService.shared` directly. This makes the dependency graph explicit and testable.

**ADR-005 — Networking Ready, Not Yet Connected**
The full networking layer (`APIService`, `APIEndpoint`, `APIConfiguration`) is built and ready for backend integration. Currently all classification is local.

### Dependency Injection Pattern

```swift
// 1. Define EnvironmentKey in App/
private struct EmotionServiceKey: EnvironmentKey {
    static let defaultValue: any EmotionAnalyzing = EmotionClassificationService.shared
}

// 2. Inject at app root
@main struct JedaApp: App {
    var body: some Scene {
        WindowGroup {
            JedaRootTabView()
                .environment(\.emotionService, EmotionClassificationService.shared)
        }
    }
}

// 3. Consume in View
struct SomeView: View {
    @Environment(\.emotionService) private var emotionService
}
```

---

## AI Models

Jeda uses two separate model systems, each scoped to a different privacy guarantee:

| System | Model | Runs | Purpose |
|--------|-------|------|---------|
| Emotion Classification | IndoBERT-int8 (fine-tuned) | On-device (Core ML) | Classifies the dominant emotion (happy, sadness, anger, fear, love) from journal text. No text leaves the device. |
| Deeper Reflection | `nvidia/nemotron-3-ultra-550b-a55b:free` | Cloud (OpenRouter) | Generates the AI-assisted deeper reflection reply, only after explicit user consent. |
| Weekly Summary | `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free` | Cloud (OpenRouter) | Generates the AI weekly summary narrative from aggregated mood/topic data. |

- Cloud models are accessed through `AIService` (`Jeda/Services/AI/`) via the OpenRouter API (`JedaAIConstants.baseURL`).
- Cloud AI features are **opt-in**: the user must accept the AI consent gate (`ReflectionAIConsentSheet`) before any text is sent off-device.
- Emotion classification is always local and unconditional — it is not covered by the AI consent gate.

---

## Project Structure

```
Jeda/
├── App/
│   ├── JedaApp.swift                    # @main entry point
│   ├── JedaEnvironment.swift            # EnvironmentKey definitions
│   ├── JedaLaunchGateView.swift         # Splash / launch gate
│   └── AIService+Environment.swift      # AI service environment key
│
├── Models/
│   ├── Emotion.swift                    # Emotion enum + metadata
│   ├── ReflectionEntry.swift            # Core journal entry model
│   ├── ReflectionStore.swift            # In-memory store
│   ├── PendingReflection.swift          # Draft reflection state
│   ├── CrisisDetection.swift            # Crisis signal model
│   ├── ReflectionAIConsentStatus.swift  # AI consent state
│   ├── JedaOnDeviceReflection.swift     # On-device reflection model
│   └── History/
│       ├── HistoryModels.swift          # History domain types
│       ├── WeekSnapshotModels.swift     # Weekly snapshot types
│       ├── HistoryWeekCatalog.swift     # Week catalog logic
│       ├── EnrichedWeekRegistry.swift   # Enriched week data
│       ├── HistoryFormatting.swift      # Display formatting helpers
│       ├── WeekSummaryCache.swift       # Summary cache model
│       └── PreviewStubs.swift           # Preview mock data
│
├── Services/
│   ├── EmotionClassificationService.swift  # Core ML actor (IndoBERT)
│   ├── IndoBertTokenizer.swift             # BPE tokenizer
│   ├── BertTextCleaner.swift               # Text preprocessing
│   ├── CrisisDetectionService.swift        # Crisis signal detection
│   ├── OnboardingProgressStore.swift       # Onboarding state persistence
│   │
│   ├── AI/
│   │   ├── AIService.swift                 # OpenRouter / LLM client
│   │   ├── AIService+WeeklySummary.swift   # Weekly summary generation
│   │   ├── AIAPIKeyProviding.swift         # API key protocol
│   │   ├── ChatCompletionModels.swift      # Chat completion types
│   │   ├── JedaAIConstants.swift           # AI prompt constants
│   │   ├── MockAICompletingService.swift   # Mock for preview/test
│   │   └── ReflectionAIConsentStore.swift  # Consent persistence
│   │
│   ├── Backend/
│   │   ├── BackendServices.swift           # Backend service coordinator
│   │   ├── EntryRepository.swift           # Remote entry CRUD
│   │   ├── SummaryRepository.swift         # Remote summary fetch
│   │   ├── SafetyService.swift             # Remote safety scanning
│   │   ├── BackendCredentials.swift        # Credential management
│   │   └── BackendDateFormat.swift         # Date serialization
│   │
│   ├── History/
│   │   ├── WeeklySummaryLoader.swift       # Summary load orchestrator
│   │   ├── WeekSummaryBuilder.swift        # Summary build logic
│   │   ├── WeekMetricsComputer.swift       # Emotion metrics computation
│   │   └── JedaAIReflectionLog.swift       # AI reflection logging
│   │
│   ├── Networking/
│   │   ├── APIService.swift                # Generic HTTP client
│   │   ├── APIEndpoint.swift               # Endpoint protocol
│   │   ├── APIConfiguration.swift          # Base URL + environment
│   │   ├── APIRequestBuilder.swift         # URLRequest builder
│   │   ├── APIError.swift                  # Network error types
│   │   ├── HTTPMethod.swift                # HTTP method enum
│   │   └── Endpoints/
│   │       ├── ChatCompletionAPIEndpoint.swift
│   │       ├── EntriesAPIEndpoint.swift
│   │       ├── SafetyAPIEndpoint.swift
│   │       └── SummariesAPIEndpoint.swift
│   │
│   └── Persistence/
│       ├── FileReflectionPersistence.swift # File-based persistence
│       └── ReflectionPersisting.swift      # Persistence protocol
│
├── ViewModels/
│   ├── Reflection/
│   │   └── DeeperReflectionViewModel.swift
│   └── History/
│       └── WeeklySummaryViewModel.swift
│
├── Views/
│   ├── JedaRootTabView.swift             # Root tab bar
│   ├── JedaReflectionView.swift          # Reflection list screen
│   ├── JedaOnboardingView.swift          # Onboarding flow
│   ├── JedaCrisisSupportSheet.swift      # Crisis support modal
│   ├── ReflectionAIConsentSheet.swift    # AI consent modal
│   ├── EmotionClassificationDemoView.swift
│   ├── EmotionCheckInSections.swift
│   ├── EmotionResultSections.swift
│   │
│   ├── Reflection/
│   │   ├── JedaReflectionDetailView.swift
│   │   ├── JedaReflectionDetailSections.swift
│   │   ├── JedaReflectionRowView.swift
│   │   ├── JedaDeeperReflectionView.swift
│   │   ├── JedaDeeperReflectionInputSection.swift
│   │   └── JedaDeeperReflectionSections.swift
│   │
│   ├── History/
│   │   ├── HistoryRootView.swift
│   │   ├── HistoryOverviewView.swift
│   │   ├── HistoryEntryDetailView.swift
│   │   ├── HistoryEntryDetailComponents.swift
│   │   ├── WeeklySummaryView.swift
│   │   ├── WeeklySummaryDetailSections.swift
│   │   ├── WeeklyStoryView.swift
│   │   └── WeeklyDailyEntriesView.swift
│   │
│   └── Reusable Views/
│       ├── JedaTheme.swift               # Color + spacing design tokens
│       ├── JedaButtons.swift             # Button styles
│       ├── JedaCharts.swift              # Chart components
│       ├── JedaGlassSurface.swift        # Glass morphism surface
│       ├── JedaGlassCompatibility.swift  # Glass OS compatibility shim
│       ├── JedaJournalInput.swift        # Multi-line text input
│       ├── JedaMoodPicker.swift          # Emotion picker component
│       ├── JedaMoodCheckInSlider.swift   # Mood intensity slider
│       ├── JedaMoodSliderCard.swift      # Slider card wrapper
│       ├── JedaMoodBreakdownViews.swift  # Mood breakdown charts
│       ├── JedaReflectionCard.swift      # Entry card component
│       ├── JedaSafetyBanner.swift        # Crisis safety banner
│       ├── JedaStateViews.swift          # Loading/empty/error states
│       ├── JedaStatsGrid.swift           # Statistics grid
│       ├── JedaWeeklyPatternCard.swift   # Weekly pattern card
│       ├── JedaHistoryComponents.swift   # History reusable components
│       ├── JedaFloatingTabBar.swift      # Custom floating tab bar
│       ├── FlowLayout.swift              # Tag/chip flow layout
│       └── JedaMoodSliderSupport.swift   # Slider support utilities
│
└── Resources/
    ├── Assets.xcassets/                  # App icons, images, colors
    └── Models/
        └── JedaEmotionIndoBERT-int8.mlpackage  # On-device ML model
```

---

## Design System

All design tokens are defined in `Jeda/Views/Reusable Views/JedaTheme.swift`. **Never use hardcoded colors or sizes anywhere else.**

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `JedaColor.sageGreen` | `#7A8B7F` | Primary CTA, active states |
| `JedaColor.dustyBlue` | `#8FA3AD` | Info, secondary accent |
| `JedaColor.warmClay` | `#C49A7C` | Highlights, tertiary accent |
| `JedaColor.terracotta` | `#B8654F` | Warm alerts, energy |
| `JedaColor.textPrimary` | — | Primary text |
| `JedaColor.textSecondary` | — | Subtitles, metadata |
| `JedaColor.background` | — | Main background |
| `JedaColor.surface` | — | Cards, elevated surfaces |
| `JedaColor.border` | — | Dividers, outlines |

```swift
// ✅ Always use JedaColor
.foregroundStyle(JedaColor.textPrimary.color)
.background(JedaColor.surface.color)

// ❌ Never hardcode
.foregroundStyle(.white)
.background(Color(hex: "#131313"))
```

### Spacing Scale

```swift
JedaSpacing.xs   // 4pt
JedaSpacing.sm   // 8pt
JedaSpacing.md   // 16pt
JedaSpacing.lg   // 24pt
JedaSpacing.xl   // 32pt
JedaSpacing.xxl  // 48pt
```

### Typography

Always use semantic text styles — never hardcode font sizes. This ensures full Dynamic Type support.

```swift
.font(.largeTitle)   // 34pt default
.font(.title)        // 28pt default
.font(.headline)     // 17pt semibold
.font(.body)         // 17pt regular
.font(.caption)      // 12pt regular
```

---

## Getting Started

### Prerequisites

- macOS with Xcode 16.4.1+
- iOS 17.6+ simulator or device
- Swift 5.9+
- Homebrew (for SwiftLint and SwiftFormat)

### Installation

```bash
# Clone the repository
git clone https://github.com/Jeda-Project/jeda-mobile.git
cd jeda-mobile

# Install linting and formatting tools
brew install swiftlint swiftformat

# Open in Xcode
open Jeda.xcodeproj
```

Swift Package Manager dependencies resolve automatically when you open the project in Xcode.

### Configuration

1. **Firebase** — Add your `GoogleService-Info.plist` to `Jeda/Resources/`. Do not commit production keys to the repository.
2. **Backend API** — Set the base URL in `Services/Networking/APIConfiguration.swift` per environment.
3. **AI Service** — Configure the API key via the `AIAPIKeyProviding` protocol. Do not hardcode keys in source files.

### Build & Run

```bash
# Build to simulator
xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run tests
xcodebuild test \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Or open `Jeda.xcodeproj` in Xcode and press `⌘R`.

---

## Development Workflow

### Branch Strategy

```
main        →  Production (TestFlight / App Store)
develop     →  Active development
feature/*   →  New features (branch from develop)
fix/*       →  Bug fixes (branch from develop, or main for hotfixes)
```

### Before Every Commit

```bash
# 1. Format (SwiftFormat handles indentation, spacing, braces)
swiftformat .

# 2. Lint (SwiftLint detects quality issues — no --fix needed)
swiftlint lint --quiet
```

**SwiftFormat** and **SwiftLint** have clearly separated responsibilities:

| Tool | Responsibility |
|------|---------------|
| SwiftFormat | Indentation, spacing, brace placement, import sorting |
| SwiftLint | Force unwrap detection, complexity, custom Jeda rules |

### Commit Format

```
type(scope): subject (max 50 chars)

Optional body: explain WHY, not WHAT
```

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Refactor without behavior change |
| `chore` | Dependency updates, config, CI |
| `docs` | Documentation only |
| `style` | Formatting, rename (no logic change) |
| `perf` | Performance optimization |
| `test` | Add or fix tests |

**Scopes:** `views`, `services`, `models`, `ml`, `networking`, `a11y`, `config`, `ci`

**Examples:**
```
feat(ml): integrate IndoBERT emotion classifier via Core ML
fix(views): correct touch target size on MoodPicker to 44pt
refactor(services): extract tokenizer into dedicated actor
```

### Hard Rules

| | Rule |
|--|------|
| ❌ | No force unwrap (`!`) outside tests or `@IBOutlet` |
| ❌ | No hardcoded colors — always use `JedaColor` |
| ❌ | No `import SwiftUI` in the Services layer |
| ❌ | No direct `SomeService.shared` access from Views — use `@Environment` |
| ❌ | No Core ML model loading on the main thread |
| ❌ | No secrets in `UserDefaults` — use Keychain |
| ❌ | No hardcoded API URL strings — use `APIConfiguration` |
| ❌ | No manual edits to `Jeda.xcodeproj/project.pbxproj` |

### Xcode Build Phase — Auto Format on Build

Add this script to Xcode → Target Jeda → Build Phases → New Run Script Phase (drag to top, before Compile Sources):

```bash
if which swiftformat > /dev/null; then
    swiftformat --config "${SRCROOT}/.swiftformat" "${SRCROOT}/Jeda"
fi
```

Uncheck **Based on dependency analysis**.

---

## CI/CD

| Workflow | Trigger | Action |
|----------|---------|--------|
| `ios-ci.yml` | PR to `main` or `develop` | Build + test on simulator |
| `ios-ci-develop.yml` | Push to `develop` | Quality gate build |
| `ios-cd-main.yml` | Push to `main` | Upload to TestFlight |
| `strip-ai-on-pr.yml` | PR opened | Strip AI session logs from PR diff |

All CI runs on `macos-latest` with `CODE_SIGNING_ALLOWED=NO` for simulator builds.

---

## Privacy

Jeda is built privacy-first:

- **On-device ML only** — Journal text and emotion classification results never leave the device. The IndoBERT model (`JedaEmotionIndoBERT-int8.mlpackage`) runs fully via Core ML.
- **No PII in analytics** — Firebase Analytics events never include journal content, names, or any personally identifiable information.
- **AI features require explicit consent** — Optional cloud AI features (weekly summaries) are gated behind an explicit `ReflectionAIConsentSheet`. Users who decline stay fully local.
- **Keychain for credentials** — All API keys and auth tokens are stored in Keychain, never `UserDefaults`.

---

## Contributing

1. Branch from `develop`: `git checkout -b feature/your-feature develop`
2. Follow the [commit format](#commit-format)
3. Run `swiftformat . && swiftlint lint --quiet` before pushing
4. Open a PR against `develop` — CI must pass before merge
5. Minimum 1 reviewer required before merging to `main`

Do not push directly to `main`.
