# /check-fix — Build Check & Auto-Fix

Run the quality gate and fix issues that can be auto-fixed.

## Steps

1. **Build to simulator**:
```bash
rtk xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -quiet
```

2. **SwiftLint** (if available):
```bash
rtk swiftlint lint --quiet
rtk swiftlint --fix  # auto-fix what can be fixed
```

3. **Report results**:
   - ✅ PASS — build succeeded, no lint errors
   - ❌ FAIL — display full error with file location and line number

4. If there are errors, diagnose with the `build-error-resolver` agent and fix.

## Output

```
Build: ✅ PASS / ❌ FAIL
SwiftLint: ✅ Clean / ⚠️ <N> warnings / ❌ <N> errors

[If there are errors, display details and the fixes applied]
```
