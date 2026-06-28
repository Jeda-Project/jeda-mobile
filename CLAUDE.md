# CLAUDE.md — Jeda iOS

## Project Identity

Jeda adalah aplikasi iOS untuk journaling kesehatan mental dengan klasifikasi emosi berbasis AI (on-device, IndoBERT + Core ML). Target pengguna: dewasa muda Indonesia yang ingin memahami pola emosi mereka.

## RTK Enforcement

**SEMUA** perintah terminal WAJIB menggunakan prefix `rtk`:

```bash
# ✅ Benar
rtk xcodebuild build -project Jeda.xcodeproj -scheme Jeda -destination 'platform=iOS Simulator,name=iPhone 16'
rtk swift test

# ❌ Dilarang
xcodebuild build ...
swift test
```

> Pengecualian: perintah di dalam hook shell scripts boleh langsung tanpa `rtk`.

## Urutan Baca & Setup Sebelum Mulai

Sebelum mengerjakan task apapun, lakukan langkah berikut secara berurutan:

1. Panggil `mcp__serena-jeda-mobile__initial_instructions` — **WAJIB** sebelum menyentuh file Swift apapun
2. Baca `AGENTS.md` — Golden Rules (wajib dipatuhi tanpa pengecualian)
3. Baca `SSOT.md` — Arsitektur, design tokens, environment variables
4. Baca `PRODUCT.md` — Konteks produk dan design philosophy
5. Baca `skills/jeda-ios/SKILL.md` — Pola kode iOS spesifik untuk Jeda

## MCP Servers

### Serena (`serena-jeda-mobile` / `serena-jeda-backend`)
- **WAJIB** panggil `mcp__serena-jeda-mobile__initial_instructions` di awal setiap sesi
- Gunakan Serena untuk semua operasi pada file `.swift`: find symbol, rename, safe delete, get diagnostics
- Gunakan `serena-jeda-backend` jika mengerjakan task yang menyentuh project backend secara bersamaan
- **JANGAN** gunakan built-in Read/Write untuk Swift file jika Serena tersedia — Serena lebih akurat

### Context7
- Gunakan `mcp__context7__resolve-library-id` + `mcp__context7__query-docs` sebelum mengimplementasikan API baru
- Wajib untuk: SwiftUI API yang belum familiar, Core ML API, Firebase SDK, URLSession patterns
- Lebih akurat dari training knowledge untuk API yang berubah cepat

### GitHub MCP
- Gunakan untuk operasi PR dan issue management
- Sudah ter-cover via `GH_TOKEN` environment variable

## Arsitektur Singkat

```
Views/          → SwiftUI only. Tidak boleh ada business logic.
Services/       → Business logic, ML, networking. Tidak ada SwiftUI import.
Models/         → Pure types, enums, protocols. Tidak ada logic.
Resources/      → Assets, Core ML model, tokenizer. Tidak ada Swift logic.
App/            → Entry point & root view setup saja.
```

## Build Commands

```bash
# Build ke simulator
rtk xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Jalankan tests
rtk xcodebuild test \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# SwiftLint (jika tersedia)
rtk swiftlint lint --quiet
```

## Commit Format

```
type(scope): subject — maks 50 karakter

Body opsional: jelaskan konteks/alasan (bukan WHAT, tapi WHY)
```

**Types:** `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `perf`, `test`

**Scope contoh:** `views`, `services`, `models`, `ml`, `networking`, `a11y`

**Contoh:**
```
feat(ml): integrate IndoBERT emotion classifier via Core ML
fix(views): correct touch target size on MoodPicker to 44pt
refactor(services): extract tokenizer into dedicated actor
```

## Naming Conventions

- **Views:** `Jeda<Name>View.swift` (screen) atau `Jeda<Name>.swift` (component)
- **Services:** `<Name>Service.swift`
- **Models:** Noun tunggal (`Emotion.swift`, `JournalEntry.swift`)
- **ViewModels:** `<Name>ViewModel.swift` (jika dibutuhkan)
- **Protocols:** Nama berakhiran `-ing` atau `-able` (`EmotionAnalyzing`, `Persistable`)

## Context Loading Strategy

Baca bagian yang relevan sebelum memulai task:

| Task | Baca |
| --- | --- |
| SwiftUI View baru | SSOT.md §Design Tokens + `rules/swiftui/patterns.md` |
| Service / business logic | SSOT.md §Architecture + `rules/swift/patterns.md` |
| Core ML / emotion classifier | SSOT.md §ML + `anti-patterns/coreml-model-loading.md` |
| Networking / endpoint baru | AGENTS.md §Networking + `rules/common/security.md` |
| Accessibility | AGENTS.md §HIG + `rules/ios/design-quality.md` |
| Keamanan / secrets / Keychain | `rules/common/security.md` + `anti-patterns/keychain-vs-userdefaults.md` |
| Testing | `rules/common/testing.md` |
| Komentar / style | `rules/common/comments.md` |
| Dependency injection | `anti-patterns/environment-injection.md` |

## Code Comments

Aturan lengkap: [`rules/common/comments.md`](.claude/rules/common/comments.md)

Ringkasan: setiap file `.swift` wajib diawali docblock berikut, **sebelum** semua import:

```swift
/**
 * Scope: FileName.swift
 * Purpose: one sentence describing what this file does.
 */
```

Tidak ada inline `//` comment. File `*View.swift` zero comment.

## Larangan Keras

- ❌ Jangan gunakan `force unwrap` (`!`) kecuali dalam test atau IBOutlet
- ❌ Jangan hardcode warna — selalu gunakan `JedaColor` dari `JedaTheme.swift`
- ❌ Jangan import SwiftUI di layer Services
- ❌ Jangan akses `EmotionClassificationService.shared` langsung dari View — gunakan `@Environment`
- ❌ Jangan load Core ML model di main thread
- ❌ Jangan tulis ke `Jeda.xcodeproj/project.pbxproj` secara manual
- ❌ Jangan simpan secrets di UserDefaults — gunakan Keychain
- ❌ Jangan gunakan hardcoded string API URL — gunakan `APIConfiguration`
