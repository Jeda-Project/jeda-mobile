# SSOT.md — Single Source of Truth — Jeda iOS

> Dokumen ini adalah referensi arsitektur utama. Tidak boleh diubah oleh Claude.

---

## Tech Stack

| Komponen | Teknologi | Versi |
|---|---|---|
| Framework | SwiftUI | iOS 17.6+ |
| Bahasa | Swift | 5.0 |
| Build Tool | Xcode | 16.4.1 |
| Dependency Manager | Swift Package Manager (SPM) | Native |
| ML Framework | Core ML | on-device |
| ML Model | IndoBERT-int8 | fine-tuned emotion classification |
| Analytics | Firebase Analytics | 12.15.0+ |
| Networking | URLSession + async/await | Native |
| Architecture | Clean Architecture + MVVM hybrid | — |

---

## Layer Ownership Map

```
Jeda/App/           → @main, AppDelegate, root view, environment setup
Jeda/Models/        → Domain types, enums, protocols (ZERO dependencies)
Jeda/Services/      → Business logic, ML inference, HTTP networking
  └─ Networking/    → APIService, APIEndpoint protocol, APIError, builders
     └─ Endpoints/  → Feature-specific endpoint definitions
Jeda/Views/         → SwiftUI screens dan reusable components
  └─ Reusable Views/ → Shared UI components (JedaButton, JedaChart, dll)
Jeda/Resources/     → Assets.xcassets, Core ML model, tokenizer vocab
skills/jeda-ios/    → Claude Code skill reference (SKILL.md, reference.md)
.claude/            → Claude Code configuration (agents, commands, hooks)
.github/workflows/  → CI/CD pipelines
```

---

## Design Tokens

### Warna (didefinisikan di `Jeda/Views/Reusable Views/JedaTheme.swift`)

```swift
// Calm/Muted Palette
enum JedaColor {
  case sageGreen    // #7A8B7F — keseimbangan, elemen primer
  case dustyBlue    // #8FA3AD — ketenangan, info
  case warmClay     // #C49A7C — kehangatan, accent
  case terracotta   // #B8654F — alert hangat, energi

  // Semantic
  case textPrimary    // teks utama
  case textSecondary  // teks sekunder/subtitle
  case background     // latar utama
  case surface        // card/surface
  case border         // garis pembatas
}
```

> **WAJIB:** Selalu gunakan `JedaColor` enum. Tidak boleh ada `Color(hex:)` atau hardcoded `.green`, `.blue`, dll di luar JedaTheme.swift.

### Spacing (di `JedaTheme.swift`)

```swift
enum JedaSpacing {
  static let xs: CGFloat = 4
  static let sm: CGFloat = 8
  static let md: CGFloat = 16
  static let lg: CGFloat = 24
  static let xl: CGFloat = 32
  static let xxl: CGFloat = 48
}
```

### Typography

Gunakan `.font(.body)`, `.font(.headline)`, dll — **bukan** `.font(.system(size: N))`. Dynamic Type harus selalu berfungsi.

---

## Arsitektur Keputusan

### ADR-001: Actor untuk Core ML Service
`EmotionClassificationService` adalah `actor` untuk memastikan model loading dan inference terjadi secara isolated dari main thread. Ini mencegah UI freeze dan race condition pada model state.

### ADR-002: Protocol-Oriented Services
Semua services expose protocol (`EmotionAnalyzing`, dll). Views bergantung pada protocol melalui `@Environment`. Ini memungkinkan mock injection di preview dan unit test.

### ADR-003: On-Device Only ML
Model `JedaEmotionIndoBERT-int8.mlpackage` berjalan sepenuhnya on-device. Tidak ada teks pengguna yang dikirim ke server untuk inference. Ini adalah privacy guarantee yang tidak boleh dilanggar.

### ADR-004: SwiftUI Form untuk Input
Gunakan SwiftUI native `Form`, `List`, `Section` untuk layout data-heavy. Hindari custom container yang fighting dengan HIG.

### ADR-005: Networking Ready, Not Yet Connected
Layer networking (`APIService`, `APIEndpoint`, `APIConfiguration`) sudah dibangun untuk future backend integration. Saat ini emotion classification sepenuhnya local. Tidak perlu backend URL production sampai backend tersedia.

---

## Environment Variables

| Variable | Lokasi | Keterangan |
|---|---|---|
| `GITHUB_PERSONAL_ACCESS_TOKEN_JEDA` | env shell | Untuk GitHub CLI (dev only) |
| Firebase config | `GoogleService-Info.plist` | **Jangan commit key production** |
| Backend API base URL | `APIConfiguration.swift` | Ganti per environment (dev/staging/prod) |

---

## CI/CD

| Workflow | Trigger | Aksi |
|---|---|---|
| `ios-ci.yml` | PR/push ke develop | Build + test di simulator |
| `ios-ci-develop.yml` | Push ke develop | Quality gate |
| `ios-cd-main.yml` | Push ke main | Upload ke TestFlight |

**Build command standar:**
```bash
xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  | xcpretty
```

---

## File yang Tidak Boleh Diedit Manual

- `Jeda.xcodeproj/project.pbxproj` — Dikelola Xcode
- `Jeda/Resources/GoogleService-Info.plist` — Firebase config, sensitive
- `Jeda/Resources/Models/JedaEmotionIndoBERT-int8.mlpackage/` — Binary ML model
- `SSOT.md`, `AGENTS.md` — Hanya developer yang boleh ubah
