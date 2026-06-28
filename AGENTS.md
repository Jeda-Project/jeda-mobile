# AGENTS.md — Golden Rules Jeda iOS

> Dokumen ini adalah sumber kebenaran untuk semua aturan arsitektur.
> Tidak boleh diubah oleh Claude. Hanya developer yang boleh memodifikasi.
> Semua aturan di sini bersifat **non-negotiable**.

---

## Kategori 1: Layer Ownership (Rules 1–4)

### Rule 1 — Views hanya boleh berisi SwiftUI
File di `Jeda/Views/` dan `Jeda/Views/Reusable Views/`:
- ✅ Boleh: SwiftUI views, `@State` lokal, `@Environment`, event handlers, computed display properties
- ❌ Dilarang: `URLSession`, `CoreML`, `UserDefaults`, `FileManager`, business logic, async data fetching langsung

### Rule 2 — Services menangani semua business logic
File di `Jeda/Services/`:
- ✅ Boleh: `actor`, `class`, `struct`; async/await; Core ML inference; networking; persistence
- ❌ Dilarang: `import SwiftUI`, rendering logic, hardcoded UI strings

### Rule 3 — Models adalah pure types
File di `Jeda/Models/`:
- ✅ Boleh: `struct`, `enum`, `protocol`, extensions dengan computed properties murni
- ❌ Dilarang: `import SwiftUI`, `URLSession`, side effects, async functions

### Rule 4 — App layer hanya bootstrap
File di `Jeda/App/`:
- ✅ Boleh: `@main`, `AppDelegate`, root view setup, environment injection
- ❌ Dilarang: business logic, UI components, service implementations

---

## Kategori 2: Dependency Injection (Rules 5–6)

### Rule 5 — Wajib gunakan Environment untuk services
```swift
// ✅ Benar — inject via environment
@Environment(\.emotionService) private var emotionService

// ❌ Salah — langsung singleton dari View
let service = EmotionClassificationService.shared
```

### Rule 6 — Services wajib protocol-oriented
Setiap service wajib punya protocol (misal: `EmotionAnalyzing`). View bergantung pada protocol, bukan concrete type — memudahkan testing dengan mock.

---

## Kategori 3: Concurrency & Thread Safety (Rules 7–8)

### Rule 7 — Core ML inference wajib di background actor
`EmotionClassificationService` adalah `actor`. Semua model loading dan inference terjadi di sana. Main thread tidak boleh pernah di-block oleh ML computation.

```swift
// ✅ Benar
Task {
  let result = try await emotionService.classify(text: input)
  await MainActor.run { self.result = result }
}

// ❌ Salah — sinkron di main thread
let result = emotionService.classifySync(text: input)
```

### Rule 8 — Tandai Sendable dengan benar
Semua types yang dikirim lintas actor boundary wajib conform `Sendable`. Hindari `@unchecked Sendable` kecuali ada alasan kuat yang didokumentasi.

---

## Kategori 4: Styling & Design System (Rules 9–11)

### Rule 9 — Tidak ada hardcoded warna
```swift
// ✅ Benar
.foregroundStyle(JedaColor.textPrimary.color)

// ❌ Salah
.foregroundStyle(Color(hex: "#7A8B7F"))
.foregroundStyle(.green)
```

### Rule 10 — SF Symbols saja untuk ikon
Tidak boleh ada image asset untuk ikon. Gunakan `Image(systemName:)`. Setiap `Emotion` case sudah punya `systemImageName` di `Emotion.swift`.

### Rule 11 — HIG Compliance wajib
- Touch target minimum **44×44 pt**
- Mendukung **Dynamic Type** — gunakan `.font(.body)` bukan `.font(.system(size: 16))`
- Setiap interactive element wajib punya **accessibility label**
- Mendukung **VoiceOver** order yang logis dengan `.accessibilityElement(children:)`

---

## Kategori 5: Networking (Rules 12–13)

### Rule 12 — Gunakan APIEndpoint protocol
Tidak boleh ada raw URL string di luar `APIConfiguration` dan `Endpoints/`. Semua endpoint didefinisikan sebagai conformance `APIEndpoint`.

```swift
// ✅ Benar
struct EmotionAPIEndpoint: APIEndpoint { ... }

// ❌ Salah
URLSession.shared.data(from: URL(string: "https://api.example.com/emotion")!)
```

### Rule 13 — Error handling wajib typed
Gunakan `APIError` enum (yang conform `LocalizedError`) untuk semua networking errors. Pesan error untuk user **wajib dalam Bahasa Indonesia**.

---

## Kategori 6: Code Quality (Rules 14–15)

### Rule 14 — Tidak ada force unwrap di production code
```swift
// ✅ Benar
guard let value = optional else { return }
let value = optional ?? defaultValue

// ❌ Salah (kecuali di test atau @IBOutlet)
let value = optional!
```

### Rule 15 — Self-Review Gate sebelum selesai
Sebelum menyatakan task complete, Claude WAJIB:
1. Build project berhasil (tidak ada compiler error)
2. Tidak ada SwiftUI import di Services layer
3. Tidak ada hardcoded warna hex di Swift files
4. Semua interactive elements punya accessibility label
5. Tidak ada force unwrap baru di production code
6. Commit message mengikuti format conventional commits
