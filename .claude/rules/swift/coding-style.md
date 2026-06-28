# Swift Coding Style

## Naming (Swift API Design Guidelines)

```swift
// ✅ Deskriptif dan jelas
func classifyEmotion(from text: String) async throws -> EmotionClassificationResult
var dominantEmotion: Emotion
let confidenceThreshold: Double = 0.6

// ❌ Terlalu singkat atau ambigu
func classify(_ t: String) -> Any
var emotion: Any
let threshold = 0.6
```

**Aturan penamaan Jeda:**
- Types: `UpperCamelCase` (`EmotionClassificationService`, `JournalEntry`)
- Functions & properties: `lowerCamelCase` (`classify`, `dominantEmotion`)
- Files: nama sama dengan type utama di dalamnya (`EmotionClassificationService.swift`)
- Constants: `lowerCamelCase` sebagai `static let` dalam enum atau type

## Value Types vs Reference Types

**Gunakan `struct` untuk:**
- Domain models (`JournalEntry`, `EmotionClassificationResult`)
- View state yang tidak di-share
- Data Transfer Objects dari network

**Gunakan `class` untuk:**
- `ObservableObject` ViewModels (dibutuhkan oleh SwiftUI)
- Objects dengan identity yang penting

**Gunakan `actor` untuk:**
- Services dengan mutable shared state (`EmotionClassificationService`)
- Singleton yang diakses dari multiple contexts

## Type Safety

```swift
// ✅ Explicit types untuk public API
func classify(text: String) async throws -> EmotionClassificationResult

// ✅ Type inference OK untuk lokal variables
let result = try await emotionService.classify(text: input)

// ❌ Hindari Any dan AnyObject
func process(data: Any) -> Any  // tidak type-safe
```

## Extensions

Gunakan extensions untuk:
- Protocol conformance (satu extension per conformance)
- Grouped functionality

```swift
// ✅ Protocol conformance di extension terpisah
extension EmotionClassificationService: EmotionAnalyzing {
    func classify(text: String) async throws -> EmotionClassificationResult { ... }
}

// ✅ Computed properties logis
extension Emotion {
    var displayName: String { ... }
    var systemImageName: String { ... }
}
```

## Optionals

```swift
// ✅ guard let untuk early exit
guard let url = URL(string: urlString) else {
    throw APIError.invalidURL
}

// ✅ if let untuk optional binding lokal
if let cached = cache[key] {
    return cached
}

// ✅ ?? untuk default value sederhana
let name = user.displayName ?? "Pengguna"

// ❌ Force unwrap di production code
let url = URL(string: urlString)!
```

## Access Control

Selalu gunakan access control yang paling restrictive:

```swift
// ✅ private untuk implementation details
private var model: MLModel?
private func loadModel() throws { ... }

// ✅ internal (default) untuk dalam module
func classify(text: String) async throws -> EmotionClassificationResult { ... }

// ✅ public hanya jika benar-benar diperlukan dari luar module
public protocol EmotionAnalyzing { ... }
```
