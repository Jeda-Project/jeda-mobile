# SwiftUI Coding Style

## View Body — Tetap Ringan

View `body` hanya boleh berisi layout dan display logic. Tidak ada computation berat:

```swift
// ✅ Computed property untuk logic sederhana
var emotionColor: Color {
    JedaColor.forEmotion(dominantEmotion).color
}

// ❌ Logic berat di body — re-evaluate setiap render
var body: some View {
    Text(entries.filter { $0.emotion == .happy }.map { $0.text }.joined(separator: ", "))
}
```

## Pecah View yang Panjang

Maks ~150 baris per View file. Pecah menjadi private sub-views atau extracted components:

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

    // ✅ Private sub-view — tetap dalam file yang sama jika kecil
    private var headerSection: some View {
        HStack { ... }
    }
}
```

## State Management Hierarchy

Gunakan jenis state yang paling sederhana yang memenuhi kebutuhan:

```swift
@State          // State lokal dalam satu View (UI-only)
@Binding        // State yang di-pass dari parent
@StateObject    // ViewModel yang owned oleh View ini
@ObservedObject // ViewModel yang di-inject dari luar
@Environment    // Dependency dari environment (services, theme)
@EnvironmentObject // Shared object dari ancestor (gunakan sparingly)
```

> JANGAN gunakan `@EnvironmentObject` untuk services — gunakan `@Environment` dengan custom key.

## className vs style

```swift
// ✅ Modifier untuk nilai statis
Text("Halo")
    .font(.body)
    .foregroundStyle(JedaColor.textPrimary.color)

// ✅ Jika perlu computed berdasarkan state — gunakan conditional modifier
Text("Halo")
    .foregroundStyle(isSelected ? JedaColor.sageGreen.color : JedaColor.textPrimary.color)

// ❌ Jangan buat custom modifier hanya untuk satu penggunaan
```

## Preview

Setiap View WAJIB punya `#Preview`:

```swift
#Preview("Default") {
    JedaMoodPicker(selectedMood: .constant(.happy))
}

#Preview("Empty State") {
    JedaMoodPicker(selectedMood: .constant(nil))
}
```

Gunakan mock data atau mock service untuk Preview agar bisa berjalan tanpa network/ML.
