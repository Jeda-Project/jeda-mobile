# Anti-Pattern: Actor Isolation Pitfalls

## Common Issues with Swift Actors in Jeda

`EmotionClassificationService` is an `actor`. This protects the ML model state from concurrent access, but there are several common anti-patterns.

---

## 1. `@MainActor` Too Broad on ViewModel

### ❌ Anti-Pattern

```swift
// Entire class marked @MainActor even though most computation could run in background
@MainActor
class JournalViewModel: ObservableObject {
    @Published var result: EmotionClassificationResult?

    func classify(text: String) async throws {
        // This runs on the main thread — blocks the UI!
        let tokenized = tokenizer.encode(text)  // expensive
        result = try await emotionService.classify(tokens: tokenized)
    }
}
```

### ✅ Correct Pattern

```swift
class JournalViewModel: ObservableObject {
    @MainActor @Published var result: EmotionClassificationResult?

    func classify(text: String) async throws {
        // Computation in background (not main thread)
        let tokenized = tokenizer.encode(text)
        let classification = try await emotionService.classify(tokens: tokenized)

        // Update UI on main thread
        await MainActor.run {
            result = classification
        }
    }
}
```

---

## 2. Accessing Actor Property from Non-Async Context

### ❌ Confusing Compiler Error

```swift
// Error: "Expression is 'async' but is not marked with 'await'"
let service = EmotionClassificationService.shared
let model = service.model  // ❌ Not allowed — model is an actor-isolated property
```

### ✅ Solution

```swift
// Accessing actor properties requires await
Task {
    let model = await EmotionClassificationService.shared.model
}

// Or better: expose a method, not a property
extension EmotionClassificationService {
    func classify(text: String) async throws -> EmotionClassificationResult {
        // Internal access to model is safe inside the actor
        let tokens = tokenizer.encode(text)
        return try model.prediction(from: tokens)
    }
}
```

---

## 3. `nonisolated` in the Wrong Place

### ❌ Anti-Pattern

```swift
actor EmotionClassificationService {
    private var model: MLModel

    // ❌ Not allowed — nonisolated func cannot access actor-isolated property
    nonisolated func classify(text: String) throws -> EmotionClassificationResult {
        return try model.prediction(...)  // Compiler error!
    }
}
```

### ✅ Use `nonisolated` Only for Stateless Methods

```swift
actor EmotionClassificationService {
    private var model: MLModel

    // ✅ classify must be async because it accesses model
    func classify(text: String) async throws -> EmotionClassificationResult {
        return try model.prediction(...)
    }

    // ✅ nonisolated is fine for pure computation with no actor state
    nonisolated func preprocessText(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
```

---

## 4. Accessing `EmotionClassificationService.shared` from a View

### ❌ Anti-Pattern

```swift
struct EmotionDemoView: View {
    var body: some View {
        Button("Classify") {
            Task {
                // ❌ Tight coupling to singleton, cannot be mocked
                let result = try await EmotionClassificationService.shared.classify(text: input)
            }
        }
    }
}
```

### ✅ Use Environment Injection

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
