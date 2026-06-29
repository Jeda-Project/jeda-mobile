# iOS Performance

## Core ML Performance

```swift
// ✅ Model loaded once via lazy singleton actor
actor EmotionClassificationService {
    private var model: JedaEmotionIndoBERT_int8?

    private func getModel() throws -> JedaEmotionIndoBERT_int8 {
        if let existing = model { return existing }
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine  // leverage Neural Engine
        let loaded = try JedaEmotionIndoBERT_int8(contentsOf: modelURL, configuration: config)
        model = loaded
        return loaded
    }
}

// ❌ Model loaded on every inference — very slow
func classify(text: String) async throws -> EmotionClassificationResult {
    let model = try JedaEmotionIndoBERT_int8(contentsOf: modelURL)  // reloads every time!
    // ...
}
```

## SwiftUI Re-render Optimization

```swift
// ✅ Split large Views — only sub-views that change will re-render
struct JournalDetailView: View {
    let entry: JournalEntry  // let, not @State for data from parent

    var body: some View {
        VStack {
            EntryHeader(entry: entry)        // re-renders only if entry changes
            EmotionResultView(entry: entry)  // independent re-render
        }
    }
}

// ❌ @ObservedObject observed too broadly
struct SomeView: View {
    @ObservedObject var viewModel: BigViewModel  // entire view re-renders when ANYTHING changes in VM
}
```

## Lazy Loading

```swift
// ✅ LazyVStack / LazyHStack for long content
ScrollView {
    LazyVStack {
        ForEach(entries) { EntryCard(entry: $0) }
    }
}

// ✅ List has built-in lazy loading
List(entries) { EntryRow(entry: $0) }
```

## Image Loading

For images loaded from URLs (future feature):
- Cache images in memory or on disk
- Use `.resizable()` + `.scaledToFill()` with `.clipped()` to avoid loading images larger than needed
- Show a placeholder while loading

## Memory Management

```swift
// ✅ [weak self] for closures captured after a delay
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    self?.updateUI()
}

// ✅ Task is cancelled when the View disappears (automatic with .task modifier)
// ❌ Task.detached cannot be cancelled
Task.detached {
    // no way to cancel this task from the View
}
```

## Network Efficiency

```swift
// ✅ Debounce for searches triggered while the user types
.onChange(of: searchText) { _, newValue in
    searchTask?.cancel()
    searchTask = Task {
        try await Task.sleep(for: .milliseconds(300))
        await search(query: newValue)
    }
}

// ✅ Cancel in-flight request when the View disappears
.task {
    await loadData()  // automatically cancelled when View is dismissed
}
```
