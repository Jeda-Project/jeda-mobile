# Jeda iOS — Reference

## Color Branding

### Palet Calm/Muted (Blue-Green Earthy)

| Token | Asset name | Hex | SwiftUI usage |
|-------|------------|-----|---------------|
| Primary | `JedaPrimary` | `#7A8B7F` | Tab aktif, tint, ikon selected |
| Secondary | `JedaSecondary` | `#8FA3AD` | Chip, badge, dekorasi |
| Accent / CTA | `JedaAccent` | `#C49A7C` | Button utama, link, FAB |
| Background light | `JedaBackgroundLight` | `#F4F1EC` | Screen background (light mode) |
| Background dark | `JedaBackgroundDark` | `#2A2E2B` | Screen background (dark mode) |
| Text primary | `JedaTextPrimary` | `#3A3D3A` | Body, heading (light mode) |
| Alert / crisis | `JedaAlert` | `#B8654F` | Error, peringatan krisis |

### Swift Color Extension

Prefer Asset Catalog colors; fallback extension for previews or before assets exist:

```swift
import SwiftUI

enum JedaColor {
    static let primary = Color("JedaPrimary", bundle: .main)
    static let secondary = Color("JedaSecondary", bundle: .main)
    static let accent = Color("JedaAccent", bundle: .main)
    static let backgroundLight = Color("JedaBackgroundLight", bundle: .main)
    static let backgroundDark = Color("JedaBackgroundDark", bundle: .main)
    static let textPrimary = Color("JedaTextPrimary", bundle: .main)
    static let alert = Color("JedaAlert", bundle: .main)

    /// Adaptive screen background.
    static let background = Color(
        light: Color(hex: 0xF4F1EC),
        dark: Color(hex: 0x2A2E2B)
    )
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
```

Place extension in `Jeda/Models/` or a dedicated `Jeda/Resources/JedaColor.swift`.

### SwiftUI Usage Examples

```swift
// Screen
ZStack {
    JedaColor.background.ignoresSafeArea()
    ScrollView { ... }
}

// Primary CTA
Button("Simpan") { ... }
    .buttonStyle(.borderedProminent)
    .tint(JedaColor.accent)

// Secondary action
Button("Batal") { ... }
    .foregroundStyle(JedaColor.secondary)

// Body text
Text(journalText)
    .foregroundStyle(JedaColor.textPrimary)

// Error — Soft terracotta, not .red
Text(errorMessage)
    .foregroundStyle(JedaColor.alert)

// Form section tint
Form { ... }
    .scrollContentBackground(.hidden)
    .background(JedaColor.background)
```

### Asset Catalog Setup

Add Color Sets under `Jeda/Resources/Assets.xcassets/`:

```
JedaPrimary.colorset          → #7A8B7F (Any Appearance)
JedaSecondary.colorset        → #8FA3AD
JedaAccent.colorset           → #C49A7C
JedaBackgroundLight.colorset  → #F4F1EC
JedaBackgroundDark.colorset   → #2A2E2B
JedaTextPrimary.colorset      → #3A3D3A (light); lighter variant for dark if needed
JedaAlert.colorset            → #B8654F
```

Set **AccentColor** in Assets to `#C49A7C` (Warm clay) so system controls inherit CTA tone.

### Dark Mode Notes

- Background: `Deep slate` `#2A2E2B` — earthy, not pure black
- Text on dark: off-white warm (~`#F4F1EC` at reduced opacity) or light sage
- Primary/Accent tetap sama; sesuaikan opacity jika kontras kurang (min WCAG AA untuk body text)

## Design System (HIG)

Referensi resmi: [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) · [Designing for iOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios)

Jeda = **HIG foundation** + **Calm/Muted brand palette**. Platform conventions menang saat bentrok dengan preferensi visual.

### Navigation

```swift
NavigationStack {
    JournalListView()
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showComposer = true } label: {
                    Label("Tulis", systemImage: "square.and.pencil")
                }
                .accessibilityLabel("Tulis journal baru")
            }
        }
}
.sheet(isPresented: $showComposer) {
    JournalComposerView()
}
```

- **Tab bar** untuk 3–5 destination utama; jangan nested tab
- **Push** untuk drill-down hierarkis; **sheet** untuk task modal/fokus singkat
- Back gesture & swipe-to-delete pada `List` — jangan override tanpa alasan

### Typography & Dynamic Type

```swift
Text("Refleksi hari ini")
    .font(.title2.weight(.semibold))
    .foregroundStyle(JedaColor.textPrimary)

Text(journalBody)
    .font(.body)
    .foregroundStyle(JedaColor.textPrimary)
    .lineSpacing(4)
```

- Gunakan text styles sistem (`.largeTitle` … `.caption2`) — otomatis scale dengan Dynamic Type
- Jangan `.font(.system(size: 14))` fixed size kecuali badge kecil
- Preview wajib untuk layout text-heavy:

```swift
#Preview("Large Dynamic Type") {
    JournalView()
        .dynamicTypeSize(.accessibility3)
}
```

### Touch Targets & Spacing

```swift
Button { ... } label: {
    Label("Analisis emosi", systemImage: "sparkles")
        .frame(maxWidth: .infinity, minHeight: 44)
}
```

- Minimum **44×44 pt** untuk semua control interaktif
- `Form`/`List` row default sudah HIG-compliant — hindari row terlalu pendek
- Spacing: `VStack(spacing: 16)`, section padding `.padding(.horizontal, 20)`

### Buttons (HIG + Jeda brand)

```swift
// Primary CTA
Button("Simpan") { save() }
    .buttonStyle(.borderedProminent)
    .tint(JedaColor.accent)
    .controlSize(.large)

// Destructive — pakai role HIG, warna alert brand
Button("Hapus", role: .destructive) { delete() }
    .tint(JedaColor.alert)

// Secondary
Button("Batal") { dismiss() }
    .buttonStyle(.bordered)
    .tint(JedaColor.secondary)
```

### Feedback & States

| State | HIG pattern |
|-------|-------------|
| Loading | `ProgressView()` inline atau overlay tipis |
| Empty | `ContentUnavailableView` (iOS 17+) dengan SF Symbol + copy singkat |
| Error | Inline text + `JedaColor.alert`; alert sheet untuk error blocking |
| Success | subtle checkmark + optional light haptic |

```swift
ContentUnavailableView {
    Label("Belum ada journal", systemImage: "book.closed")
} description: {
    Text("Mulai tulis refleksi harianmu.")
} actions: {
    Button("Tulis sekarang") { ... }
        .buttonStyle(.borderedProminent)
        .tint(JedaColor.accent)
}
```

### Accessibility Checklist

- [ ] Setiap `Button` / ikon tap punya `accessibilityLabel` (Bahasa Indonesia)
- [ ] Gunakan `accessibilityHint` untuk aksi non-obvious
- [ ] `LabeledContent` untuk pasangan label-value
- [ ] Jangan andalkan warna saja — tambah icon atau teks
- [ ] Uji VoiceOver flow end-to-end
- [ ] Kontras teks min 4.5:1 (body), 3:1 (large text)

### Anti-patterns (hindari)

- Custom tab bar / navigation bar saat standar cukup
- Floating action button gaya Material Design
- Font size fixed yang break Dynamic Type
- Pure black background atau pure white flash
- Ikon custom bitmap untuk aksi standar (settings, delete, share)
- Modal bertumpuk > 2 level

## SF Symbols

Referensi: [SF Symbols](https://developer.apple.com/sf-symbols/) · cari di app **SF Symbols** (macOS)

### Usage Pattern

```swift
// Standalone icon
Image(systemName: "gearshape")
    .font(.body)
    .foregroundStyle(JedaColor.primary)
    .symbolRenderingMode(.hierarchical)

// Label (preferred for buttons & list rows)
Label("Pengaturan", systemImage: "gearshape")

// With emotion model — existing pattern in Emotion.swift
Label(emotion.displayName, systemImage: emotion.systemImageName)
    .foregroundStyle(JedaColor.primary)
    .symbolRenderingMode(.hierarchical)
```

### Symbol Properties (iOS 17+)

```swift
Image(systemName: "heart.fill")
    .symbolEffect(.bounce, value: isLiked)       // feedback
    .symbolVariant(isSelected ? .fill : .none)   // state
```

Prefer **variable value** & **hierarchical rendering** untuk nuansa calm — hindari `.multicolor` kecuali emoji-like emphasis.

### Selected / Unselected States

| Unselected | Selected |
|------------|----------|
| `heart` | `heart.fill` |
| `bookmark` | `bookmark.fill` |
| `star` | `star.fill` |
| `sun.max` | `sun.max.fill` |
| `gearshape` | `gearshape.fill` |

### Jeda Domain Mapping

Extend enums with `systemImageName` — jangan scatter string di views:

```swift
enum JournalTab: CaseIterable, Identifiable {
    case home, history, profile

    var id: Self { self }

    var title: String {
        switch self {
        case .home: "Journal"
        case .history: "Riwayat"
        case .profile: "Profil"
        }
    }

    var systemImageName: String {
        switch self {
        case .home: "book.closed"
        case .history: "clock.arrow.circlepath"
        case .profile: "person.circle"
        }
    }
}
```

### Emotion Icons (existing)

| Emotion | SF Symbol |
|---------|-----------|
| sadness | `cloud.rain` |
| anger | `flame` |
| love | `heart.fill` |
| fear | `exclamationmark.triangle` |
| happy | `sun.max.fill` |

### When Custom Icons Are OK

Hanya jika **tidak ada SF Symbol** yang cocok:

- App icon & launch branding
- Ilustrasi onboarding/emotional empty state (opsional)
- Logo partner pihak ketiga

Simpan di `Assets.xcassets` sebagai vector PDF @1x. Tetap sediakan `accessibilityLabel`.

### TabView Example

```swift
TabView(selection: $selectedTab) {
    ForEach(JournalTab.allCases) { tab in
        tabContent(for: tab)
            .tabItem {
                Label(tab.title, systemImage: tab.systemImageName)
            }
            .tag(tab)
    }
}
.tint(JedaColor.primary)
```

## Reusable Views

Lokasi: `Jeda/Views/Reusable Views/` · Living catalog: `DesignSystemShowcaseView.swift`

### Design tokens (`JedaTheme.swift`)

| Token | Values | Usage |
|-------|--------|-------|
| `JedaColor.sage` | Sage green | Primary, highlight |
| `JedaColor.dustyBlue` | Dusty blue | Secondary, chips |
| `JedaColor.clay` | Warm clay | Accent / CTA |
| `JedaColor.terracotta` | Soft terracotta | Warning / crisis |
| `JedaColor.background` | Adaptive | Screen base |
| `JedaColor.textPrimary` / `textSecondary` | Adaptive | Body & label |
| `JedaSpacing` | xs=6, sm=10, md=16, lg=24, xl=32 | Layout spacing |
| `JedaRadius` | chip=18, control=22, card=28 | Corner radius |
| `JedaTypography` | display, title, headline, body, caption | System rounded fonts |

### Layout & containers

**`JedaScreenBackground`** — gradient background untuk semua screen:

```swift
ScrollView { ... }
    .background { JedaScreenBackground() }
```

**`JedaSection(title, subtitle:, content:)`** — section dengan heading:

```swift
JedaSection("Weekly Pattern", subtitle: "Ringkasan 7 hari") {
    JedaWeeklyPatternCard(...)
}
```

**`JedaGlassSurface(cornerRadius:tint:isInteractive:padding:content:)`** — card glass:

```swift
JedaGlassSurface(tint: JedaColor.sage.opacity(0.12)) {
    VStack { ... }
}
```

Defaults: `cornerRadius = JedaRadius.card`, `padding = JedaSpacing.lg`.

### Glass compatibility (`JedaGlassCompatibility.swift`)

Jangan panggil langsung di view/screen:

```swift
.glassEffect(...)              // ❌
Glass.regular                  // ❌
GlassEffectContainer           // ❌
.buttonStyle(.glassProminent)  // ❌
```

Gunakan wrapper:

| Wrapper | iOS 26+ | iOS < 26 |
|---------|---------|----------|
| `.jedaGlassEffect(tint:isInteractive:in:)` | Liquid Glass | ultraThinMaterial + tint |
| `JedaGlassEffectContainer(spacing:)` | Native container | VStack fallback |
| `.jedaProminentButtonStyle(tint:)` | `.glassProminent` | `.borderedProminent` |
| `.jedaGlassButtonStyle(tint:)` | `.glass` | `.bordered` |
| `.jedaIconGlassButtonStyle(tint:)` | `.glass` | material circle |

### Buttons

```swift
// Primary CTA
JedaButton("Simpan check-in", systemImage: "checkmark", kind: .primary) { save() }

// Secondary
JedaButton("Cerita lebih dalam", systemImage: "arrow.up.message", kind: .secondary) { ... }

// Warning / crisis
JedaButton("Lihat bantuan", systemImage: "phone", kind: .warning) { ... }

// Icon only (44×44 pt)
JedaIconButton(systemImage: "gearshape", accessibilityLabel: "Buka pengaturan") { ... }
```

### Input & check-in

**`JedaJournalInput(title:prompt:text:)`** — journal entry:

```swift
@State private var journalText = ""

JedaJournalInput(
    title: "Apa yang paling berat hari ini?",
    prompt: "Jawab singkat juga cukup.",
    text: $journalText
)
```

**`JedaMoodPicker(selectedMood:)`** — 5-level mood picker:

```swift
@State private var mood: JedaMood = .neutral

JedaMoodPicker(selectedMood: $mood)
```

**`JedaMoodSliderCard(value:action:)`** — slider 0...1 + CTA:

```swift
@State private var sliderValue = 0.5

JedaMoodSliderCard(value: $sliderValue) { proceed() }
```

### Feature cards

**`JedaReflectionCard(phrase:question:action:)`** — AI reflection prompt:

```swift
JedaReflectionCard(
    phrase: "backlog",
    question: "Bagian mana yang paling menguras kepala?"
) { openDeepReflection() }
```

**`JedaWeeklyPatternCard(topics:moodTrend:reliefNote:)`** — weekly insights:

```swift
JedaWeeklyPatternCard(
    topics: ["backlog", "energi sore"],
    moodTrend: "Lebih berat di awal minggu.",
    reliefNote: "Progress kecil terasa membantu."
)
```

**`JedaSafetyBanner(action:)`** — crisis resource CTA:

```swift
JedaSafetyBanner { showHelpResources() }
```

### Charts

```swift
JedaMoodTrendChartCard(
    title: "Mood 7 hari",
    subtitle: "Baca arah minggu.",
    points: [
        .init(day: "Sen", score: 2.0),
        .init(day: "Sel", score: 3.5)
    ]
)

JedaTopicBarChartCard(
    title: "Topik sering muncul",
    subtitle: "Kata yang berulang.",
    items: [
        .init(topic: "backlog", count: 5),
        .init(topic: "fokus", count: 4)
    ]
)
```

### States

```swift
JedaStateCard(kind: .loading)
JedaStateCard(kind: .empty, actionTitle: "Mulai check-in") { startCheckIn() }
JedaStateCard(kind: .error, actionTitle: "Coba lagi") { retry() }
```

Kinds: `.loading` (redacted placeholder), `.empty`, `.error`.

### Menambah reusable view baru

1. Buat file di `Jeda/Views/Reusable Views/Jeda<Name>.swift`
2. Prefix `Jeda`, compose dari `JedaGlassSurface` + token theme
3. Terima data via `let` / `@Binding` — **tanpa** service call di dalam view
4. Glass lewat `.jedaGlassEffect()` / `JedaGlassSurface`
5. Tambah `#Preview` + entry di `DesignSystemShowcaseView`
6. Screen hanya compose — logic di ViewModel/service terpisah

### Screen vs reusable — decision tree

```
Butuh UI yang sudah ada di katalog?  → Reuse komponen Jeda*
Butuh variasi kecil?                  → Pass parameter, jangan fork styling
Butuh pola UI baru yang dipakai ≥2x?  → Buat reusable view baru
Sekali pakai, sangat spesifik?        → Boleh inline di screen (minimal)
```

## Environment Injection Pattern

```swift
// Service+Environment.swift
private struct FooAnalyzingKey: EnvironmentKey {
    static let defaultValue: any FooAnalyzing = FooService.shared
}

extension EnvironmentValues {
    var fooService: any FooAnalyzing {
        get { self[FooAnalyzingKey.self] }
        set { self[FooAnalyzingKey.self] = newValue }
    }
}
```

Inject at app root for tests/previews:

```swift
SomeView()
    .environment(\.fooService, MockFooService())
```

## Actor + Shared Singleton

```swift
actor FooService: FooAnalyzing {
    static let shared: FooService = {
        do { return try FooService() }
        catch { fatalError("Failed to load FooService: \(error.localizedDescription)") }
    }()

    init(bundle: Bundle = .main) throws { ... }
}
```

## APIEndpoint with Throwing Body

Prefer `encodedBody()` when errors must propagate:

```swift
extension APIRequestBuilder {
    init(configuration: APIConfiguration, endpoint: some APIEndpoint) throws {
        // Uses endpoint.body; for strict encoding use encodedBody() in custom init
    }
}
```

In endpoint enum, `body` can use `try? encodeBody` for convenience; use throwing variant in tests.

## View Async Pattern

```swift
private func loadData() async {
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
        items = try await apiService.fetchItems()
    } catch {
        items = []
        errorMessage = error.localizedDescription
    }
}
```

## Core ML Bundle Lookup

```swift
private static func modelURL(in bundle: Bundle) -> URL? {
    if let compiled = bundle.url(forResource: "ModelName", withExtension: "mlmodelc") {
        return compiled
    }
    return bundle.url(forResource: "ModelName", withExtension: "mlpackage")
}
```

## Tool Compatibility

This skill uses the open **Agent Skills** format (`SKILL.md` + YAML frontmatter). It works in:

| Tool | Project path | Personal path |
|------|--------------|---------------|
| Cursor | `.cursor/skills/jeda-ios/` | `~/.cursor/skills/jeda-ios/` |
| Claude Code | `.claude/skills/jeda-ios/` | `~/.claude/skills/jeda-ios/` |

Canonical source in this repo: `skills/jeda-ios/` (symlinked to both tool paths).

Invoke manually in Claude Code: `/jeda-ios`
