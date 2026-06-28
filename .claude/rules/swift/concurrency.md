# Swift Concurrency

## Structured Concurrency — Prinsip Utama

Selalu gunakan structured concurrency. Hindari callback-based pattern kecuali berinteraksi dengan legacy API.

```swift
// ✅ Structured — lifecycle terikat ke scope
func loadData() async throws -> [JournalEntry] {
    async let entries = journalService.fetchEntries()
    async let emotions = emotionService.fetchHistory()
    return try await combineResults(entries, emotions)
}

// ❌ Unstructured — lifecycle tidak terkontrol
Task.detached {
    // Hindari ini kecuali ada alasan kuat
}
```

## `async/await` vs Callback

```swift
// ✅ async/await — lebih mudah dibaca dan di-debug
func classify(text: String) async throws -> EmotionClassificationResult {
    let tokens = try tokenizer.encode(text)
    return try await model.predict(tokens)
}

// ❌ Callback (hindari untuk kode baru)
func classify(text: String, completion: @escaping (Result<EmotionClassificationResult, Error>) -> Void) {
    DispatchQueue.global().async {
        // ...
    }
}
```

## `@MainActor` — Scope Seminimal Mungkin

```swift
// ❌ Seluruh class di-mark @MainActor — computation terjadi di main thread
@MainActor
class JournalViewModel: ObservableObject {
    func loadEntries() async {
        entries = await journalService.fetchAll()  // network di main thread!
    }
}

// ✅ Hanya property UI yang butuh @MainActor
class JournalViewModel: ObservableObject {
    @MainActor @Published var entries: [JournalEntry] = []
    @MainActor @Published var isLoading = false

    func loadEntries() async {
        await MainActor.run { isLoading = true }
        let fetched = try? await journalService.fetchAll()  // berjalan di background
        await MainActor.run {
            entries = fetched ?? []
            isLoading = false
        }
    }
}
```

## Task dalam View

```swift
struct JournalView: View {
    @State private var entries: [JournalEntry] = []

    var body: some View {
        List(entries) { entry in EntryRow(entry: entry) }
            .task {
                // ✅ .task otomatis di-cancel saat View hilang
                entries = (try? await journalService.fetchAll()) ?? []
            }
    }
}
```

## Task Group untuk Parallel Work

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

Semua types yang melintas actor boundary WAJIB `Sendable`:

```swift
// ✅ struct otomatis Sendable jika semua property Sendable
struct EmotionClassificationResult: Sendable {
    let dominantEmotion: Emotion
    let confidence: Double
}

// ✅ Jika butuh class yang Sendable, gunakan final + nonisolated storage
final class EmotionCache: @unchecked Sendable {
    private let lock = NSLock()
    private var cache: [String: EmotionClassificationResult] = [:]
    // ... thread-safe implementation
}
```
