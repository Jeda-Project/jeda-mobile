# Swift Coding Style

## Naming (Swift API Design Guidelines)

```swift
// ✅ Descriptive and clear
func classifyEmotion(from text: String) async throws -> EmotionClassificationResult
var dominantEmotion: Emotion
let confidenceThreshold: Double = 0.6

// ❌ Too short or ambiguous
func classify(_ t: String) -> Any
var emotion: Any
let threshold = 0.6
```

**Jeda naming rules:**
- Types: `UpperCamelCase` (`EmotionClassificationService`, `JournalEntry`)
- Functions & properties: `lowerCamelCase` (`classify`, `dominantEmotion`)
- Files: same name as the primary type inside (`EmotionClassificationService.swift`)
- Constants: `lowerCamelCase` as `static let` inside an enum or type

## Value Types vs Reference Types

**Use `struct` for:**
- Domain models (`JournalEntry`, `EmotionClassificationResult`)
- View state that is not shared
- Data Transfer Objects from the network

**Use `class` for:**
- `ObservableObject` ViewModels (required by SwiftUI)
- Objects where identity matters

**Use `actor` for:**
- Services with mutable shared state (`EmotionClassificationService`)
- Singletons accessed from multiple contexts

## Type Safety

```swift
// ✅ Explicit types for public API
func classify(text: String) async throws -> EmotionClassificationResult

// ✅ Type inference is fine for local variables
let result = try await emotionService.classify(text: input)

// ❌ Avoid Any and AnyObject
func process(data: Any) -> Any  // not type-safe
```

## Extensions

Use extensions for:
- Protocol conformance (one extension per conformance)
- Grouped functionality

```swift
// ✅ Protocol conformance in a separate extension
extension EmotionClassificationService: EmotionAnalyzing {
    func classify(text: String) async throws -> EmotionClassificationResult { ... }
}

// ✅ Logical computed properties
extension Emotion {
    var displayName: String { ... }
    var systemImageName: String { ... }
}
```

## Optionals

```swift
// ✅ guard let for early exit
guard let url = URL(string: urlString) else {
    throw APIError.invalidURL
}

// ✅ if let for local optional binding
if let cached = cache[key] {
    return cached
}

// ✅ ?? for simple default values
let name = user.displayName ?? "Pengguna"

// ❌ Force unwrap in production code
let url = URL(string: urlString)!
```

## Access Control

Always use the most restrictive access control:

```swift
// ✅ private for implementation details
private var model: MLModel?
private func loadModel() throws { ... }

// ✅ internal (default) for within the module
func classify(text: String) async throws -> EmotionClassificationResult { ... }

// ✅ public only when truly needed from outside the module
public protocol EmotionAnalyzing { ... }
```
