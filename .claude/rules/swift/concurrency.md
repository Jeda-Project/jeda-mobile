# Swift Concurrency

## Structured Concurrency — Core Principle

Always use structured concurrency. Avoid callback-based patterns unless interacting with a legacy API.

```swift
// ✅ Structured — lifecycle is tied to scope
func loadData() async throws -> [JournalEntry] {
    async let entries = journalService.fetchEntries()
    async let emotions = emotionService.fetchHistory()
    return try await combineResults(entries, emotions)
}

// ❌ Unstructured — lifecycle is not controlled
Task.detached {
    // Avoid this unless there is a strong reason
}
```

## `async/await` vs Callback

```swift
// ✅ async/await — easier to read and debug
func classify(text: String) async throws -> EmotionClassificationResult {
    let tokens = try tokenizer.encode(text)
    return try await model.predict(tokens)
}

// ❌ Callback (avoid for new code)
func classify(text: String, completion: @escaping (Result<EmotionClassificationResult, Error>) -> Void) {
    DispatchQueue.global().async {
        // ...
    }
}
```

## `@MainActor` — Narrowest Possible Scope

```swift
// ❌ Entire class marked @MainActor — computation runs on main thread
@MainActor
class JournalViewModel: ObservableObject {
    func loadEntries() async {
        entries = await journalService.fetchAll()  // network on main thread!
    }
}

// ✅ Only UI properties need @MainActor
class JournalViewModel: ObservableObject {
    @MainActor @Published var entries: [JournalEntry] = []
    @MainActor @Published var isLoading = false

    func loadEntries() async {
        await MainActor.run { isLoading = true }
        let fetched = try? await journalService.fetchAll()  // runs in background
        await MainActor.run {
            entries = fetched ?? []
            isLoading = false
        }
    }
}
```

## Task in a View

```swift
struct JournalView: View {
    @State private var entries: [JournalEntry] = []

    var body: some View {
        List(entries) { entry in EntryRow(entry: entry) }
            .task {
                // ✅ .task is automatically cancelled when the View disappears
                entries = (try? await journalService.fetchAll()) ?? []
            }
    }
}
```

## Task Group for Parallel Work

```swift
func loadDashboardData() async throws -> DashboardData {
    try await withThrowingTaskGroup(of: DashboardSection.self) { group in
        group.addTask { try await .entries(journalService.fetchRecent()) }
        group.addTask { try await .emotions(emotionService.fetchWeeklySummary()) }

        var sections: [DashboardSection] = []
        for try await section in group {
            sections.append(section)
        }
        return DashboardData(sections: sections)
    }
}
```

## Sendable

All types crossing actor boundaries MUST be `Sendable`:

```swift
// ✅ struct is automatically Sendable if all properties are Sendable
struct EmotionClassificationResult: Sendable {
    let dominantEmotion: Emotion
    let confidence: Double
}

// ✅ If a Sendable class is needed, use final + nonisolated storage
final class EmotionCache: @unchecked Sendable {
    private let lock = NSLock()
    private var cache: [String: EmotionClassificationResult] = [:]
    // ... thread-safe implementation
}
```
