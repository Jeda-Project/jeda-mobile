# Development Workflow

## Checklist Sebelum Mulai Task

1. Panggil `mcp__serena-jeda-mobile__initial_instructions`
2. Baca `AGENTS.md` dan `SSOT.md`
3. Pahami scope task — tanya jika tidak jelas
4. Cari pattern yang sudah ada sebelum buat yang baru
5. Gunakan Context7 untuk lookup API yang belum familiar

## Checklist Sebelum Commit

- [ ] Build berhasil: `rtk xcodebuild build -project Jeda.xcodeproj -scheme Jeda -destination 'platform=iOS Simulator,name=iPhone 16'`
- [ ] SwiftLint clean: `rtk swiftlint lint --quiet` (jika tersedia)
- [ ] Tidak ada SwiftUI import di Services layer
- [ ] Tidak ada hardcoded warna hex
- [ ] Semua interactive element punya accessibilityLabel
- [ ] Tidak ada force unwrap baru di production code
- [ ] Test yang relevan lulus
- [ ] Commit message mengikuti conventional format

## Self-Review Gate (Rule 15 dari AGENTS.md)

Sebelum menyatakan task selesai, Claude WAJIB:
1. Re-read perubahan yang dibuat
2. Jalankan build check
3. Verifikasi tidak ada pelanggaran Golden Rules
4. Pastikan error handling tidak di-swallow

## Penggunaan RTK

**SEMUA** perintah terminal harus dengan prefix `rtk`:
```bash
rtk xcodebuild build ...
rtk swiftlint lint ...
rtk swift test
rtk git status
```

## Workflow Fitur Baru

```
1. /plan <nama fitur>          → Buat plan, tunggu konfirmasi
2. Implementasi per layer:
   Models → Services → Views
3. /check-fix                  → Pastikan build & lint clean
4. /review                     → Code review
5. /commit                     → Draft commit message
6. git commit -m "..."         → Eksekusi commit
7. /create-pr                  → Buat PR ke main
```
