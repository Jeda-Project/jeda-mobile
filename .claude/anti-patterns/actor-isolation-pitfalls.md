# Anti-Pattern: Actor Isolation Pitfalls

## Masalah Umum dengan Swift Actors di Jeda

`EmotionClassificationService` adalah `actor`. Ini melindungi state ML model dari concurrent access, tapi ada beberapa anti-pattern umum.

---

## 1. `@MainActor` Terlalu Luas pada ViewModel

### ❌ Anti-Pattern

```swift
// Seluruh class di-mark @MainActor padahal sebagian besar computation bisa di background
@MainActor
class JournalViewModel: ObservableObject {
    @Published var result: EmotionClassificationResult?

    func classify(text: String) async throws {
        // Ini berjalan di main thread — memblokir UI!
        let tokenized = tokenizer.encode(text)  // expensive
        result = try await emotionService.classify(tokens: tokenized)
    }
}
```

### ✅ Pattern yang Benar

```swift
class JournalViewModel: ObservableObject {
    @MainActor @Published var result: EmotionClassificationResult?

    func classify(text: String) async throws {
        // Computation di background (bukan main thread)
        let tokenized = tokenizer.encode(text)
        let classification = try await emotionService.classify(tokens: tokenized)

        // Update UI di main thread
        await MainActor.run {
            result = classification
        }
    }
}
```

---

## 2. Akses Actor Property dari Non-Async Context

### ❌ Compiler Error yang Membingungkan

```swift
// Error: "Expression is 'async' but is not marked with 'await'"
let service = EmotionClassificationService.shared
let model = service.model  // ❌ Tidak bisa — model adalah actor-isolated property
```

### ✅ Solusi

```swift
// Akses actor property harus dengan await
Task {
    let model = await EmotionClassificationService.shared.model
}

// Atau lebih baik: expose method, bukan property
extension EmotionClassificationService {
    func classify(text: String) async throws -> EmotionClassificationResult {
        // Internal access ke model aman di dalam actor
        let tokens = tokenizer.encode(text)
        return try model.prediction(from: tokens)
    }
}
```

---

## 3. `nonisolated` yang Salah Tempat

### ❌ Anti-Pattern

```swift
actor EmotionClassificationService {
    private var model: MLModel

    // ❌ Tidak bisa — nonisolated func tidak bisa akses actor-isolated property
    nonisolated func classify(text: String) throws -> EmotionClassificationResult {
        return try model.prediction(...)  // Compiler error!
    }
}
```

### ✅ Gunakan `nonisolated` Hanya untuk Stateless Methods

```swift
actor EmotionClassificationService {
    private var model: MLModel

    // ✅ classify harus async karena akses model
    func classify(text: String) async throws -> EmotionClassificationResult {
        return try model.prediction(...)
    }

    // ✅ nonisolated OK untuk pure computation tanpa actor state
    nonisolated func preprocessText(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
```

---

## 4. Akses `EmotionClassificationService.shared` dari View

### ❌ Anti-Pattern

```swift
struct EmotionDemoView: View {
    var body: some View {
        Button("Classify") {
            Task {
                // ❌ Tight coupling ke singleton, tidak bisa di-mock
                let result = try await EmotionClassificationService.shared.classify(text: input)
            }
        }
    }
}
```

### ✅ Gunakan Environment Injection

```swift
struct EmotionDemoView: View {
    @Environment(\.emotionService) private var emotionService  // ✅ Protocol-based

    var body: some View {
        Button("Classify") {
            Task {
                let result = try await emotionService.classify(text: input)
            }
        }
    }
}
```
