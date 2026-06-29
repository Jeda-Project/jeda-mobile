# AGENTS.md — Golden Rules Jeda iOS

> This document is the source of truth for all architecture rules.
> Must not be changed by Claude. Only developers may modify it.
> All rules here are **non-negotiable**.

---

## Category 1: Layer Ownership (Rules 1–4)

### Rule 1 — Views may only contain SwiftUI
Files in `Jeda/Views/` and `Jeda/Views/Reusable Views/`:
- ✅ Allowed: SwiftUI views, local `@State`, `@Environment`, event handlers, computed display properties
- ❌ Forbidden: `URLSession`, `CoreML`, `UserDefaults`, `FileManager`, business logic, direct async data fetching

### Rule 2 — Services handle all business logic
Files in `Jeda/Services/`:
- ✅ Allowed: `actor`, `class`, `struct`; async/await; Core ML inference; networking; persistence
- ❌ Forbidden: `import SwiftUI`, rendering logic, hardcoded UI strings

### Rule 3 — Models are pure types
Files in `Jeda/Models/`:
- ✅ Allowed: `struct`, `enum`, `protocol`, extensions with pure computed properties
- ❌ Forbidden: `import SwiftUI`, `URLSession`, side effects, async functions

### Rule 4 — App layer is bootstrap only
Files in `Jeda/App/`:
- ✅ Allowed: `@main`, `AppDelegate`, root view setup, environment injection
- ❌ Forbidden: business logic, UI components, service implementations

---

## Category 2: Dependency Injection (Rules 5–6)

### Rule 5 — Must use Environment for services
```swift
// ✅ Correct — inject via environment
@Environment(\.emotionService) private var emotionService

// ❌ Wrong — direct singleton from a View
let service = EmotionClassificationService.shared
```

### Rule 6 — Services must be protocol-oriented
Every service must have a protocol (e.g. `EmotionAnalyzing`). Views depend on the protocol, not the concrete type — this makes mock-based testing possible.

---

## Category 3: Concurrency & Thread Safety (Rules 7–8)

### Rule 7 — Core ML inference must run on a background actor
`EmotionClassificationService` is an `actor`. All model loading and inference happen there. The main thread must never be blocked by ML computation.

```swift
// ✅ Correct
Task {
  let result = try await emotionService.classify(text: input)
  await MainActor.run { self.result = result }
}

// ❌ Wrong — synchronous on the main thread
let result = emotionService.classifySync(text: input)
```

### Rule 8 — Mark Sendable correctly
All types crossing actor boundaries must conform to `Sendable`. Avoid `@unchecked Sendable` unless there is a strong, documented reason.

---

## Category 4: Styling & Design System (Rules 9–11)

### Rule 9 — No hardcoded colors
```swift
// ✅ Correct
.foregroundStyle(JedaColor.textPrimary.color)

// ❌ Wrong
.foregroundStyle(Color(hex: "#7A8B7F"))
.foregroundStyle(.green)
```

### Rule 10 — SF Symbols only for icons
No image assets are allowed for icons. Use `Image(systemName:)`. Every `Emotion` case already has a `systemImageName` in `Emotion.swift`.

### Rule 11 — HIG Compliance is required
- Minimum touch target **44×44 pt**
- Must support **Dynamic Type** — use `.font(.body)` instead of `.font(.system(size: 16))`
- Every interactive element must have an **accessibility label**
- Must support a logical **VoiceOver** order via `.accessibilityElement(children:)`

---

## Category 5: Networking (Rules 12–13)

### Rule 12 — Use the APIEndpoint protocol
No raw URL strings are allowed outside `APIConfiguration` and `Endpoints/`. All endpoints must be defined as `APIEndpoint` conformances.

```swift
// ✅ Correct
struct EmotionAPIEndpoint: APIEndpoint { ... }

// ❌ Wrong
URLSession.shared.data(from: URL(string: "https://api.example.com/emotion")!)
```

### Rule 13 — Error handling must be typed
Use the `APIError` enum (conforming to `LocalizedError`) for all networking errors. User-facing error messages **must be in Indonesian**.

---

## Category 6: Code Quality (Rules 14–15)

### Rule 14 — No force unwrap in production code
```swift
// ✅ Correct
guard let value = optional else { return }
let value = optional ?? defaultValue

// ❌ Wrong (except in tests or @IBOutlet)
let value = optional!
```

### Rule 15 — Self-Review Gate before completion
Before declaring a task complete, Claude MUST:
1. Confirm the project builds successfully (no compiler errors)
2. Confirm there is no SwiftUI import in the Services layer
3. Confirm there are no hardcoded hex colors in Swift files
4. Confirm all interactive elements have an accessibility label
5. Confirm there is no new force unwrap in production code
6. Confirm the commit message follows the conventional commits format
