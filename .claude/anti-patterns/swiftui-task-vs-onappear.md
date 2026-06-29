# Anti-Pattern: `.task {}` vs `.onAppear {}`

## Problem

Using `.onAppear` for async work creates a Task that cannot be cancelled when the View disappears, potentially causing memory leaks and updates on an already-dismissed View.

## ❌ Anti-Pattern

```swift
struct JedaJournalListView: View {
    @State private var entries: [JournalEntry] = []

    var body: some View {
        List(entries) { entry in
            JournalEntryRow(entry: entry)
        }
        .onAppear {
            // ❌ This Task is not cancelled when the View disappears
            Task {
                entries = try await journalService.fetchEntries()
            }
        }
    }
}
```

**Problems:**
- The Task keeps running even after the View is dismissed (e.g., user taps Back before the fetch completes)
- If the fetch completes after the View is dismissed, state is updated on a View that no longer exists
- Does not take advantage of SwiftUI lifecycle binding

## ✅ Correct Pattern

```swift
struct JedaJournalListView: View {
    @State private var entries: [JournalEntry] = []

    var body: some View {
        List(entries) { entry in
            JournalEntryRow(entry: entry)
        }
        .task {
            // ✅ Task is automatically cancelled when the View disappears
            do {
                entries = try await journalService.fetchEntries()
            } catch {
                // Handle error
            }
        }
    }
}
```

## When to Use `.onAppear`

`.onAppear` is appropriate for:
- Sync operations (set analytics flag, update local `@State`)
- Side effects that do not require cancellation

```swift
.onAppear {
    // ✅ Sync, no cancellation needed
    Analytics.logEvent("journal_list_viewed", parameters: nil)
    hasSeenList = true
}
```

## When to Use `.task`

`.task` for all async work:
- Networking / API calls
- Core ML inference
- Disk I/O
- Any async operation that should be cancelled when the View disappears

## Note

`.task` with an `id:` parameter re-runs the task every time the `id` value changes — useful for refresh:

```swift
.task(id: refreshTrigger) {
    entries = try await journalService.fetchEntries()
}
```
