# /check-fix — Build Check & Auto-Fix

Jalankan quality gate dan perbaiki issues yang bisa di-auto-fix.

## Langkah

1. **Build ke simulator**:
```bash
rtk xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet
```

2. **SwiftLint** (jika tersedia):
```bash
rtk swiftlint lint --quiet
rtk swiftlint --fix  # auto-fix yang bisa di-fix
```

3. **Report hasil**:
   - ✅ PASS — build berhasil, tidak ada lint error
   - ❌ FAIL — tampilkan error lengkap dengan lokasi file dan baris

4. Jika ada error, diagnosa dengan agent `build-error-resolver` dan fix.

## Output

```
Build: ✅ PASS / ❌ FAIL
SwiftLint: ✅ Clean / ⚠️ <N> warnings / ❌ <N> errors

[Jika ada error, tampilkan detail dan fix yang diterapkan]
```
