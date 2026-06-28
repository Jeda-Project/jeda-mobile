# /build-sim — Build ke Simulator

Build project Jeda ke iPhone 16 Simulator dan tampilkan hasil.

## Langkah

```bash
rtk xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet \
  2>&1 | grep -E "(error:|warning:|BUILD (SUCCEEDED|FAILED))"
```

Jika `xcpretty` tersedia, gunakan untuk output yang lebih bersih:
```bash
rtk xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  | xcpretty
```

## Output

```
🔨 Building Jeda for iPhone 16 Simulator...

✅ BUILD SUCCEEDED
   Build time: <N>s

atau

❌ BUILD FAILED
   <error details>
   <file:line — error message>
```

Jika build gagal, gunakan agent `build-error-resolver` untuk diagnosa.
