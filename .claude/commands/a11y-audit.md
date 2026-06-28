# /a11y-audit [path] — Accessibility Audit

Audit aksesibilitas SwiftUI views untuk memastikan VoiceOver, Dynamic Type, dan HIG compliance.

## Penggunaan
```
/a11y-audit                          # audit semua Views/
/a11y-audit Jeda/Views/JedaMoodPicker.swift
```

## Langkah

1. **Scan file Swift** yang ditentukan (atau semua di `Views/` jika tidak ada path)
2. **Gunakan agent `jeda-a11y-guard`** untuk audit menyeluruh
3. Cek secara spesifik:
   - `.accessibilityLabel` pada semua button dan icon
   - Tidak ada `.font(.system(size:))` — Dynamic Type violation
   - Touch target minimum 44×44 pt
   - VoiceOver grouping dengan `.accessibilityElement(children:)`
   - Animasi yang support `accessibilityReduceMotion`

## Output

Laporan dengan prioritas:
- 🚫 Pelanggaran kritis (block commit)
- ⚠️ Perlu peningkatan
- ✅ Sudah aksesibel
