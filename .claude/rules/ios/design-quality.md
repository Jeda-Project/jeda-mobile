# iOS Design Quality

## HIG Compliance (Human Interface Guidelines)

### Touch Targets
- Minimum **44×44 pt** for all interactive elements
- If a visual element is small (20pt icon), expand the hit area with padding or `.contentShape`

```swift
// ✅ Small icon with adequate hit area
Button(action: deleteEntry) {
    Image(systemName: "trash")
        .font(.system(size: 20))
}
.frame(width: 44, height: 44)  // 44pt hit area

// ✅ Or use contentShape
Image(systemName: "trash")
    .contentShape(Rectangle().size(CGSize(width: 44, height: 44)))
    .onTapGesture { deleteEntry() }
```

### Navigation
- Use clear, concise titles (max 2 words)
- Back button must work consistently
- No custom navigation that fights the iOS system

### Typography
```swift
// ✅ Text styles — automatically support Dynamic Type
.font(.largeTitle)   // 34pt default
.font(.title)        // 28pt default
.font(.title2)       // 22pt default
.font(.headline)     // 17pt semibold
.font(.body)         // 17pt regular
.font(.callout)      // 16pt regular
.font(.subheadline)  // 15pt regular
.font(.footnote)     // 13pt regular
.font(.caption)      // 12pt regular

// ❌ Hardcoded size — does not support Dynamic Type
.font(.system(size: 17))
```

## JedaColor Design System

ALWAYS use `JedaColor` from `JedaTheme.swift`:

```swift
// ✅ Semantic colors
.foregroundStyle(JedaColor.textPrimary.color)
.background(JedaColor.surface.color)
.tint(JedaColor.sageGreen.color)

// ❌ Hardcoded colors
.foregroundStyle(.white)
.background(Color(hex: "#131313"))
.tint(Color(red: 0.48, green: 0.55, blue: 0.50))
```

**Jeda Color Palette:**
| Token | Hex | Usage |
|-------|-----|-------|
| `sageGreen` | #7A8B7F | CTA, primary accent |
| `dustyBlue` | #8FA3AD | Info, secondary accent |
| `warmClay` | #C49A7C | Highlights, tertiary accent |
| `terracotta` | #B8654F | Warm alert, energy |
| `textPrimary` | — | Primary text |
| `textSecondary` | — | Subtitle, metadata |
| `background` | — | Main background |
| `surface` | — | Card, elevated surface |
| `border` | — | Divider lines |

## Spacing Consistency

Use `JedaSpacing` constants:

```swift
VStack(spacing: JedaSpacing.md) {  // 16pt
    // content
}
.padding(.horizontal, JedaSpacing.lg)  // 24pt
```

## SF Symbols

```swift
// ✅ All icons from SF Symbols
Image(systemName: "heart.fill")
Image(systemName: "book.fill")
Image(systemName: "face.smiling")

// ❌ Custom image asset for icons available in SF Symbols
Image("custom-heart-icon")
```

Use `.symbolRenderingMode(.hierarchical)` or `.symbolVariant` for the appropriate variant.

## Animation

- Animations must be purposeful — every animation should improve comprehension or delight
- Use `withAnimation(.easeInOut(duration: 0.2))` for standard transitions
- Support `@Environment(\.accessibilityReduceMotion)`:

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation? {
    reduceMotion ? nil : .easeInOut(duration: 0.3)
}
```
