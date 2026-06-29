# /build-sim — Build to Simulator

Build the Jeda project to the iPhone 17 Pro Simulator and display the result.

## Steps

```bash
rtk xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -quiet \
  2>&1 | grep -E "(error:|warning:|BUILD (SUCCEEDED|FAILED))"
```

If `xcpretty` is available, use it for cleaner output:
```bash
rtk xcodebuild build \
  -project Jeda.xcodeproj \
  -scheme Jeda \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  | xcpretty
```

## Output

```
🔨 Building Jeda for iPhone 17 Pro Simulator...

✅ BUILD SUCCEEDED
   Build time: <N>s

or

❌ BUILD FAILED
   <error details>
   <file:line — error message>
```

If the build fails, use the `build-error-resolver` agent for diagnosis.
