# /test — Jalankan XCTest Suite

Jalankan semua unit tests di simulator dan tampilkan hasil.

## Langkah

```bash
rtk xcodebuild test \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet \
  2>&1 | grep -E "(Test (Case|Suite)|passed|failed|error:)"
```

## Output

```
🧪 Running Jeda Tests...

Test Suite 'All tests' started
  ✅ test_classify_withSadText_returnsSadnessEmotion — passed (0.023s)
  ✅ test_apiService_whenNetworkUnavailable_returnsNetworkError — passed (0.011s)
  ❌ test_tokenizer_withEmptyString_throwsError — FAILED
     <failure message>

Results: <N> tests, <N> passed, <N> failed
Coverage: <N>% (target: ≥80% untuk Services)
```

Jika ada test failure, diagnosa root cause sebelum fix.
Coverage di bawah 80% untuk core Services perlu ditambah test.
