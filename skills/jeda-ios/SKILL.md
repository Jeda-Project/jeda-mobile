---
name: jeda-ios
description: >-
  Guides iOS/SwiftUI development for the Jeda app following Apple HIG design
  system, reusable views in Jeda/Views/Reusable Views, SF Symbols, Calm/Muted
  color branding, glass compatibility, networking, and Core ML patterns. Use
  when building Jeda screens, composing UI from JedaButton/JedaGlassSurface,
  views, API endpoints, models, or on-device ML integration.
---

# Jeda iOS Development

## Project Overview

- **App**: Jeda — journal emotion analysis (on-device Core ML + REST API)
- **Stack**: SwiftUI, async/await, Core ML, Firebase, URLSession
- **Target**: iOS 17.6+, Swift 5
- **Xcode project**: `Jeda.xcodeproj`, scheme `Jeda`

## Folder Structure

Place new code in the correct layer:

```
Jeda/
├── App/              # @main entry, AppDelegate (Firebase)
├── Models/           # Domain types, enums, result structs
├── Views/            # SwiftUI views (one primary view per file)
│   └── Reusable Views/  # Design system components — reuse, jangan duplikasi
├── Services/         # Business logic, ML, helpers
│   └── Networking/   # HTTP layer (shared)
│       └── Endpoints/  # Per-domain APIEndpoint enums
└── Resources/        # Assets, Core ML models, tokenizer files
    ├── Assets.xcassets
    ├── Models/       # .mlpackage / .mlmodelc
    └── Tokenizer/    # vocab.txt, tokenizer config
```

| Task | Location |
|------|----------|
| New screen | `Jeda/Views/` |
| Reusable UI component | `Jeda/Views/Reusable Views/` |
| Domain model | `Jeda/Models/` |
| On-device / local logic | `Jeda/Services/` |
| REST endpoint | `Jeda/Services/Networking/Endpoints/` |
| Shared HTTP infra | `Jeda/Services/Networking/` (rarely add files) |
| Core ML model | `Jeda/Resources/Models/` |
| Static assets | `Jeda/Resources/Assets.xcassets` |

**After adding Swift files**: register them in `Jeda.xcodeproj/project.pbxproj` (or via Xcode) so they compile.

## Coding Conventions

- Conform shared types to `Sendable` where crossing concurrency boundaries
- User-facing errors: `LocalizedError` with Indonesian messages (see `APIError`, `EmotionClassificationError`)
- File header: standard Xcode comment block with filename and project name
- Prefer `final class` / `struct` / `enum` over inheritance
- Use `// MARK: -` to group sections in larger files
- Keep views thin — delegate logic to services

## Networking

### Layering

1. **`APIConfiguration`** — base URL, default headers, timeout
2. **`APIEndpoint` protocol** — path, method, headers, query, body
3. **Domain enum** — e.g. `EmotionAPIEndpoint` in `Endpoints/`
4. **`APIService`** — generic `request(_:responseType:)` / `requestVoid(_:)`
5. **Optional wrapper** — e.g. `EmotionAPIService` for typed feature API

### Adding a New API Domain

Create `Jeda/Services/Networking/Endpoints/<Feature>APIEndpoint.swift`:

```swift
struct FooRequest: Encodable, Sendable { ... }
struct FooResponse: Decodable, Sendable { ... }

enum FooAPIEndpoint: APIEndpoint {
    case create(FooRequest)
    case list(page: Int)

    var path: String { ... }
    var method: HTTPMethod { ... }
    var queryItems: [URLQueryItem]? { ... }
    var body: Data? { ... }  // use encodeBody(_:) from APIEndpoint extension
}

struct FooAPIService: Sendable {
    private let api: APIService
    init(api: APIService = .shared) { self.api = api }

    func create(...) async throws -> FooResponse {
        try await api.request(FooAPIEndpoint.create(...), responseType: FooResponse.self)
    }
}
```

Call from views via `async throws` — never block the main thread.

## On-Device ML Services

Pattern from `EmotionClassificationService`:

1. Define a **protocol** (`EmotionAnalyzing`) for testability
2. Implement as **`actor`** when model/state must be isolated
3. Load Core ML from bundle (`Resources/Models/`)
4. Expose via **SwiftUI Environment** (`Service+Environment.swift`)
5. Throw typed errors conforming to `LocalizedError`

Views inject with `@Environment(\.emotionService)`.

## Color Branding — Calm/Muted (Blue-Green Earthy)

Jeda memakai palet **Calm/Muted**: earthy blue-green, hangat, tidak klinis. Gunakan token di bawah — jangan hardcode warna di luar palet.

| Role | Warna | Hex | Alasan |
|------|-------|-----|--------|
| Primary | Sage green | `#7A8B7F` | Tenang, grounding — bukan biru korporat yang dingin |
| Secondary | Dusty blue | `#8FA3AD` | Komplemen sage, tetap calm dengan nuansa berbeda |
| Accent / CTA | Warm clay | `#C49A7C` | Sentuhan hangat agar produk tidak terasa klinis |
| Background (light) | Off-white warm | `#F4F1EC` | Nyaman di mata untuk sesi menulis panjang |
| Background (dark) | Deep slate | `#2A2E2B` | Earthy, tetap hangat walau dark mode |
| Text primary | Charcoal soft | `#3A3D3A` | Kontras cukup tanpa terlalu tajam |
| Alert / crisis | Soft terracotta | `#B8654F` | Beda jelas, tapi tidak memicu kepanikan |

**Aturan UI:**

- Background layar: `Off-white warm` (light) / `Deep slate` (dark)
- Tombol utama & link: `Warm clay` (accent), teks di atasnya putih atau charcoal
- Navigasi, ikon aktif, highlight: `Sage green`
- Badge, chip, ilustrasi sekunder: `Dusty blue`
- Body text: `Charcoal soft` — hindari pure black (`#000`)
- Error / peringatan krisis: `Soft terracotta` — **bukan** merah sistem iOS
- Hindari: biru sistem default, neon, kontras tajam, pure white `#FFF` sebagai background penuh

Simpan warna di `Jeda/Resources/Assets.xcassets` sebagai Color Set (support light/dark). Implementasi SwiftUI: lihat [reference.md — Color Branding](reference.md#color-branding).

## Design System — Apple HIG

Jeda mengikuti **[Human Interface Guidelines (HIG)](https://developer.apple.com/design/human-interface-guidelines/)** sebagai fondasi design system. Palet Calm/Muted adalah **brand layer** di atas konvensi platform — jangan melawan pola iOS.

**Prinsip inti:**

- **Native first** — pakai komponen SwiftUI standar (`NavigationStack`, `Form`, `List`, `TabView`, `.sheet`, `.alert`) sebelum custom UI
- **Familiar patterns** — navigasi hierarkis, tab untuk section utama, sheet untuk task singkat, toolbar untuk aksi kontekstual
- **Clarity & deference** — UI mendukung konten journal; minim distraksi, whitespace cukup
- **Depth via hierarchy** — typography & spacing, bukan shadow berlebihan
- **Feedback** — loading (`ProgressView`), success/error state jelas, haptic untuk aksi penting (`UIImpactFeedbackGenerator`)
- **Accessibility** — Dynamic Type, VoiceOver label di setiap ikon/tombol, kontras WCAG AA, jangan andalkan warna saja
- **Adaptivity** — support light/dark mode, safe area, landscape; uji dengan Dynamic Type besar

**Layout & spacing (HIG-aligned):**

- Minimum touch target: **44×44 pt**
- Padding horizontal layar: **16–20 pt**
- Section spacing: **8–12 pt** dalam form, **16–24 pt** antar blok konten
- Typography: **system font** (`.body`, `.headline`, `.title2`) — jangan custom font kecuali diminta

**Komponen yang disarankan:**

| Use case | Komponen HIG |
|----------|--------------|
| Input journal | `TextEditor` / `TextField` dalam `Form` |
| Aksi utama | `.buttonStyle(.borderedProminent)` + `JedaColor.accent` |
| Aksi sekunder | `.buttonStyle(.bordered)` atau plain `Button` |
| Navigasi | `NavigationStack` + `.navigationTitle` + `.toolbar` |
| Tab utama | `TabView` + `Label(title:systemImage:)` |
| Konfirmasi | `.alert` / `.confirmationDialog` |
| Detail / edit | `.sheet` / `.navigationDestination` |

Detail HIG + contoh SwiftUI: [reference.md — Design System](reference.md#design-system-hig).

## Icons — SF Symbols

**Default: SF Symbols untuk semua ikon UI.** Hindari asset PNG/SVG custom kecuali logo app atau ilustrasi khusus yang tidak ada di SF Symbols.

**Aturan:**

- Pakai `Image(systemName:)` atau `Label("...", systemImage: "...")`
- Simpan nama symbol di model/enum (contoh: `Emotion.systemImageName`)
- State selected: variant `.fill` (mis. `heart` → `heart.fill`)
- Warna ikon: `JedaColor.primary` (aktif), `JedaColor.secondary` (inaktif/dekoratif)
- Rendering: `.symbolRenderingMode(.hierarchical)` untuk nuansa calm; `.monochrome` untuk toolbar
- Ukuran ikon ikuti text: `.font(.body)` / `.title2` — jangan hardcode frame kecuali touch target
- Setiap ikon interaktif wajib punya `accessibilityLabel`

**Mapping umum Jeda:**

| Konteks | SF Symbol |
|---------|-----------|
| Journal / tulis | `square.and.pencil`, `book.closed` |
| Emosi sedih | `cloud.rain` |
| Emosi marah | `flame` |
| Emosi cinta | `heart.fill` |
| Emosi takut | `exclamationmark.triangle` |
| Emosi bahagia | `sun.max.fill` |
| Simpan | `checkmark.circle.fill` |
| Hapus | `trash` |
| Pengaturan | `gearshape` |
| Info / bantuan | `info.circle` |

Daftar lengkap & contoh kode: [reference.md — SF Symbols](reference.md#sf-symbols).

## Reusable Views

Komponen UI Jeda ada di **`Jeda/Views/Reusable Views/`**. **Reuse dulu, buat baru hanya jika belum ada.**

### Aturan

- Screen/feature view (`Jeda/Views/`) = **komposisi** reusable views + state/logic
- Jangan duplikasi styling (warna, radius, glass, typography) di screen — pakai token `JedaColor`, `JedaSpacing`, `JedaTypography`, `JedaRadius`
- Glass effect **wajib** lewat `JedaGlassSurface` / `.jedaGlassEffect()` — jangan panggil API iOS 26 langsung
- Setiap reusable view wajib `#Preview`; screen baru ikut pola `DesignSystemShowcaseView`
- Naming: prefix **`Jeda`** + peran (`JedaButton`, `JedaJournalInput`)

### Katalog komponen

| Komponen | Use case |
|----------|----------|
| `JedaScreenBackground` | Background layar dengan gradient brand |
| `JedaSection` | Heading section + subtitle + content |
| `JedaGlassSurface` | Card/container glass (Liquid Glass iOS 26+ / material fallback) |
| `JedaButton` / `JedaIconButton` | CTA primary, secondary, warning |
| `JedaJournalInput` | Input journal dengan title, prompt, counter |
| `JedaMoodPicker` | Pilih mood 5 level (Berat → Ringan) |
| `JedaMoodSliderCard` | Slider mood + CTA lanjut |
| `JedaReflectionCard` | Kartu refleksi AI |
| `JedaWeeklyPatternCard` | Pattern tracker mingguan |
| `JedaMoodTrendChartCard` / `JedaTopicBarChartCard` | Grafik mood & topik |
| `JedaStateCard` | Loading / empty / error state |
| `JedaSafetyBanner` | Safety guardrail krisis |

Token design: `JedaTheme.swift` (`JedaColor`, `JedaSpacing`, `JedaTypography`, `JedaRadius`).

### Pola komposisi screen

```swift
NavigationStack {
    ScrollView {
        VStack(alignment: .leading, spacing: JedaSpacing.xl) {
            JedaSection("Check-in", subtitle: "...") {
                JedaMoodPicker(selectedMood: $mood)
                JedaJournalInput(title: "...", prompt: "...", text: $text)
                JedaButton("Simpan", systemImage: "checkmark", kind: .primary) { save() }
            }
        }
        .padding(.horizontal, JedaSpacing.lg)
    }
    .background { JedaScreenBackground() }
}
```

Referensi lengkap API & contoh: [reference.md — Reusable Views](reference.md#reusable-views). Living catalog: `DesignSystemShowcaseView.swift`.

## SwiftUI Views

- Root navigation: `NavigationStack`
- Forms: `Form` + `Section` for structured input
- Icons: SF Symbols via `Label` / `Image(systemName:)` — see Icons section above
- Async work: `Task { await ... }` from button actions
- Loading state: `@State private var isLoading` + `ProgressView`
- Errors: `@State private var errorMessage: String?` with `.foregroundStyle(JedaColor.alert)` (Soft terracotta)
- Previews: `#Preview { ... }` at bottom of view file; include `.dynamicTypeSize(.accessibility3)` preview when layout is text-heavy

## App Bootstrap

`JedaApp.swift` configures Firebase via `AppDelegate` and sets root view. Inject environment values at root if needed.

## Build & CI

```bash
xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

CI runs on PRs to `main` / `develop` via `.github/workflows/ios-ci.yml`.

## Checklist for New Features

```
- [ ] File placed in correct Jeda/ subfolder
- [ ] Added to Xcode project (pbxproj)
- [ ] Types are Sendable where needed
- [ ] Errors use LocalizedError (Indonesian)
- [ ] API follows APIEndpoint pattern (if network)
- [ ] Service exposed via protocol + Environment (if injected)
- [ ] View uses async/await, not blocking main thread
- [ ] #Preview included for new views
- [ ] Warna dari palet Calm/Muted, bukan system colors / hardcoded hex acak
- [ ] UI mengikuti HIG (native components, 44pt touch target, Dynamic Type)
- [ ] Ikon memakai SF Symbols; custom asset hanya jika tidak ada alternatif
- [ ] Ikon/tombol interaktif punya accessibilityLabel
- [ ] Screen pakai reusable views; styling lewat JedaTheme token
- [ ] Glass lewat JedaGlassSurface / jedaGlassEffect (bukan API iOS 26 langsung)
```

## Additional Resources

- Reusable views, HIG, SF Symbols, color tokens: [reference.md](reference.md)
