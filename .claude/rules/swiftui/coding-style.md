# SwiftUI Coding Style

## View Body — Keep It Lightweight

The View `body` should only contain layout and display logic. No heavy computation:

```swift
// ✅ Computed property for simple logic
var emotionColor: Color {
    JedaColor.forEmotion(dominantEmotion).color
}

// ❌ Heavy logic in body — re-evaluated on every render
var body: some View {
    Text(entries.filter { $0.emotion == .happy }.map { $0.text }.joined(separator: ", "))
}
```

## Split Long Views

Max ~150 lines per View file. Break into private sub-views or extracted components:

```swift
struct JournalDetailView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: JedaSpacing.lg) {
                headerSection
                emotionResultSection
                entryTextSection
            }
        }
    }

    // ✅ Private sub-view — keep in the same file if small
    private var headerSection: some View {
        HStack { ... }
    }
}
```

## State Management Hierarchy

Use the simplest state type that meets the need:

```swift
@State          // Local state within a single View (UI-only)
@Binding        // State passed down from a parent
@StateObject    // ViewModel owned by this View
@ObservedObject // ViewModel injected from outside
@Environment    // Dependency from the environment (services, theme)
@EnvironmentObject // Shared object from an ancestor (use sparingly)
```

> DO NOT use `@EnvironmentObject` for services — use `@Environment` with a custom key.

## Modifiers vs Style

```swift
// ✅ Modifier for static values
Text("Halo")
    .font(.body)
    .foregroundStyle(JedaColor.textPrimary.color)

// ✅ If computed from state — use a conditional modifier
Text("Halo")
    .foregroundStyle(isSelected ? JedaColor.sageGreen.color : JedaColor.textPrimary.color)

// ❌ Do not create a custom modifier for a single use
```

## Preview

Every View MUST have a `#Preview`:

```swift
#Preview("Default") {
    JedaMoodPicker(selectedMood: .constant(.happy))
}

#Preview("Empty State") {
    JedaMoodPicker(selectedMood: .constant(nil))
}
```

Use mock data or a mock service in Previews so they can run without network or ML.
