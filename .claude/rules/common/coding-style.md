# Coding Style — Common

## Immutability

SELALU gunakan value types (`struct`, `enum`) untuk domain model. Hindari mutasi jika bisa diganti dengan copy-on-write:

```swift
// ✅ Benar — immutable update
var updated = entry
updated.mood = .happy

// ❌ Salah — mutasi di tempat tanpa kontrol
entry.mood = .happy  // langsung mutasi di referensi shared
```

Rationale: `struct` di Swift adalah value type — aman untuk concurrency dan mudah di-test.

## Core Principles

### KISS
- Pilih solusi paling sederhana yang benar-benar bekerja
- Hindari premature abstraction — tiga View yang mirip tidak perlu langsung di-extract
- Optimalkan untuk keterbacaan, bukan kepintaran

### DRY
- Extract logika yang benar-benar berulang ke `ViewModifier`, extension, atau utility
- Jangan copy-paste styling — buat `JedaButtonStyle` atau custom `ViewModifier`
- Abstraksi hanya ketika repetisi nyata, bukan spekulatif

### YAGNI
- Jangan buat protocol/abstraction sebelum ada dua implementasi
- Mulai simple dengan `struct`, naik ke `class`/`actor` hanya jika dibutuhkan
- Jangan siapkan "hook untuk future feature" yang belum pasti ada

## File Organization

BANYAK FILE KECIL > SEDIKIT FILE BESAR:

- Satu file = satu type utama (satu View, satu Service, satu Model)
- Maks ~150 baris per file — jika lebih, pertimbangkan untuk dipecah
- Organisasi by feature, bukan by type:
  ```
  // ✅ By feature
  Journal/JournalEntry.swift
  Journal/JournalService.swift
  Journal/JournalListView.swift

  // ❌ By type (sulit navigate)
  Models/JournalEntry.swift
  Services/JournalService.swift
  Views/JournalListView.swift
  ```

## Error Handling

SELALU tangani error secara eksplisit:

- `throws` function: handle atau propagate, jangan `try?` kecuali failure truly acceptable
- User-facing error messages dalam **Bahasa Indonesia** (sesuai target pengguna Jeda)
- Log error ke console di debug, ke analytics di production
- Jangan swallow error dengan `catch {}`

## Input Validation

Validasi di boundary sistem:
- Validasi input user sebelum dikirim ke Service
- Jangan percaya data dari network response — decode dengan `Codable` + error handling
- Teks jurnal yang kosong harus di-handle sebelum dikirim ke ML inference

## Code Smells yang Harus Dihindari

### Deep Nesting
Gunakan early return / guard:
```swift
// ❌ Deep nesting
func process() {
    if isValid {
        if hasData {
            if !isEmpty {
                // logic
            }
        }
    }
}

// ✅ Early return
func process() {
    guard isValid else { return }
    guard hasData else { return }
    guard !isEmpty else { return }
    // logic
}
```

### Magic Numbers
```swift
// ❌
.frame(minWidth: 44, minHeight: 44)

// ✅
.frame(minWidth: JedaSpacing.touchTarget, minHeight: JedaSpacing.touchTarget)
```

### Long Functions
Pecah fungsi panjang menjadi private helpers dengan nama yang jelas.
