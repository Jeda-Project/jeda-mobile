# SwiftUI Patterns

## Loading / Error / Empty State

Use the existing `JedaStateViews` for consistency:

```swift
struct JournalListView: View {
    @State private var state: ViewState<[JournalEntry]> = .loading

    var body: some View {
        switch state {
        case .loading:
            JedaLoadingView()
        case .empty:
            JedaEmptyView(message: "Belum ada jurnal. Mulai tulis hari ini!")
        case .loaded(let entries):
            List(entries) { EntryRow(entry: $0) }
        case .error(let message):
            JedaErrorView(message: message, retryAction: loadEntries)
        }
    }
}

enum ViewState<T> {
    case loading
    case empty
    case loaded(T)
    case error(String)
}
```

## List & Lazy Loading

```swift
// ✅ List for scrollable data — SwiftUI handles reuse automatically
List(entries) { entry in
    EntryRow(entry: entry)
}

// ✅ LazyVStack if a custom layout is needed inside a ScrollView
ScrollView {
    LazyVStack(spacing: JedaSpacing.md) {
        ForEach(entries) { entry in
            EntryCard(entry: entry)
        }
    }
    .padding()
}

// ❌ VStack for long lists — loads everything at once
VStack {
    ForEach(entries) { entry in  // not lazy — poor performance
        EntryCard(entry: entry)
    }
}
```

## Navigation

```swift
// ✅ NavigationStack (iOS 16+)
NavigationStack {
    JournalListView()
        .navigationTitle("Jurnal Saya")
        .navigationDestination(for: JournalEntry.self) { entry in
            JournalDetailView(entry: entry)
        }
}

// ❌ NavigationView (deprecated in iOS 16+)
NavigationView { ... }
```

## Sheet & Full Screen Cover

```swift
// ✅ State-driven presentation
@State private var showingNewEntry = false

var body: some View {
    Button("Tulis Jurnal") { showingNewEntry = true }
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView()
        }
}
```

## ViewModifier for Repeated Styling

If the same styling appears in ≥3 places, extract it into a `ViewModifier`:

```swift
struct JedaCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(JedaSpacing.md)
            .background(JedaColor.surface.color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(JedaColor.border.color, lineWidth: 0.5)
            )
    }
}

extension View {
    func jedaCard() -> some View {
        modifier(JedaCardModifier())
    }
}
```
