# /test — Run XCTest Suite

Run all unit tests on the simulator and display the results.

## Steps

```bash
rtk xcodebuild test \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
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
Coverage: <N>% (target: ≥80% for Services)
```

If there are test failures, diagnose the root cause before fixing.
Coverage below 80% for core Services requires additional tests.
