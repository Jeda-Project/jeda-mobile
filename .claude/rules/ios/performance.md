# iOS Performance

## Core ML Performance

```swift
// ✅ Model dimuat sekali via lazy singleton actor
actor EmotionClassificationService {
    private var model: JedaEmotionIndoBERT_int8?

    private func getModel() throws -> JedaEmotionIndoBERT_int8 {
        if let existing = model { return existing }
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine  // manfaatkan Neural Engine
        let loaded = try JedaEmotionIndoBERT_int8(contentsOf: modelURL, configuration: config)
        model = loaded
        return loaded
    }
}

// ❌ Model dimuat setiap inference — sangat lambat
func classify(text: String) async throws -> EmotionClassificationResult {
    let model = try JedaEmotionIndoBERT_int8(contentsOf: modelURL)  // load ulang setiap kali!
    // ...
}
```

## SwiftUI Re-render Optimization

```swift
// ✅ Pecah View besar — hanya sub-view yang berubah yang re-render
struct JournalDetailView: View {
    let entry: JournalEntry  // let, bukan @State untuk data dari parent

    var body: some View {
        VStack {
            EntryHeader(entry: entry)        // re-render hanya jika entry berubah
            EmotionResultView(entry: entry)  // independent re-render
        }
    }
}

// ❌ @ObservedObject yang di-observe terlalu luas
struct SomeView: View {
    @ObservedObject var viewModel: BigViewModel  // seluruh view re-render saat APAPUN berubah di VM
}
```

## Lazy Loading

```swift
// ✅ LazyVStack / LazyHStack untuk konten panjang
ScrollView {
    LazyVStack {
        ForEach(entries) { EntryCard(entry: $0) }
    }
}

// ✅ List punya built-in lazy loading
List(entries) { EntryRow(entry: $0) }
```

## Image Loading

Untuk gambar yang di-load dari URL (future feature):
- Cache images di memory atau disk
- Gunakan `.resizable()` + `.scaledToFill()` dengan `.clipped()` agar tidak memuat image lebih besar dari dibutuhkan
- Tampilkan placeholder saat loading

## Memory Management

```swift
// ✅ [weak self] untuk closure yang captured setelah delay
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    self?.updateUI()
}

// ✅ Task di-cancel saat View hilang (otomatis dengan .task modifier)
// ❌ Task.detached yang tidak bisa di-cancel
Task.detached {
    // tidak ada cara cancel task ini dari View
}
```

## Network Efficiency

```swift
// ✅ Debounce untuk pencarian yang trigger saat user mengetik
.onChange(of: searchText) { _, newValue in
    searchTask?.cancel()
    searchTask = Task {
        try await Task.sleep(for: .milliseconds(300))
        await search(query: newValue)
    }
}

// ✅ Cancel in-flight request saat View hilang
.task {
    await loadData()  // otomatis di-cancel saat View dismiss
}
```
