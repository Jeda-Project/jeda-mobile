# iOS Design Quality

## HIG Compliance (Human Interface Guidelines)

### Touch Targets
- Minimum **44×44 pt** untuk semua interactive element
- Jika visual element kecil (icon 20pt), perbesar hit area dengan padding atau `.contentShape`

```swift
// ✅ Icon kecil dengan hit area yang cukup
Button(action: deleteEntry) {
    Image(systemName: "trash")
        .font(.system(size: 20))
}
.frame(width: 44, height: 44)  // hit area 44pt

// ✅ Atau gunakan contentShape
Image(systemName: "trash")
    .contentShape(Rectangle().size(CGSize(width: 44, height: 44)))
    .onTapGesture { deleteEntry() }
```

### Navigation
- Gunakan title yang jelas dan singkat (maks 2 kata)
- Back button harus berfungsi secara konsisten
- Tidak ada custom navigation yang fighting dengan sistem iOS

### Typography
```swift
// ✅ Text styles — otomatis support Dynamic Type
.font(.largeTitle)   // 34pt default
.font(.title)        // 28pt default
.font(.title2)       // 22pt default
.font(.headline)     // 17pt semibold
.font(.body)         // 17pt regular
.font(.callout)      // 16pt regular
.font(.subheadline)  // 15pt regular
.font(.footnote)     // 13pt regular
.font(.caption)      // 12pt regular

// ❌ Hardcoded size — tidak support Dynamic Type
.font(.system(size: 17))
```

## JedaColor Design System

SELALU gunakan `JedaColor` dari `JedaTheme.swift`:

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
| Token | Hex | Penggunaan |
|-------|-----|-----------|
| `sageGreen` | #7A8B7F | CTA, primary accent |
| `dustyBlue` | #8FA3AD | Info, secondary accent |
| `warmClay` | #C49A7C | Highlights, terciary accent |
| `terracotta` | #B8654F | Alert hangat, energi |
| `textPrimary` | — | Teks utama |
| `textSecondary` | — | Subtitle, metadata |
| `background` | — | Latar utama |
| `surface` | — | Card, elevated surface |
| `border` | — | Garis pembatas |

## Spacing Consistency

Gunakan `JedaSpacing` constants:

```swift
VStack(spacing: JedaSpacing.md) {  // 16pt
    // content
}
.padding(.horizontal, JedaSpacing.lg)  // 24pt
```

## SF Symbols

```swift
// ✅ Semua ikon dari SF Symbols
Image(systemName: "heart.fill")
Image(systemName: "book.fill")
Image(systemName: "face.smiling")

// ❌ Custom image asset untuk ikon yang tersedia di SF Symbols
Image("custom-heart-icon")
```

Gunakan `.symbolRenderingMode(.hierarchical)` atau `.symbolVariant` untuk variasi yang tepat.

## Animation

- Animasi harus purposeful — setiap animasi harus meningkatkan comprehension atau delight
- Gunakan `withAnimation(.easeInOut(duration: 0.2))` untuk transisi standard
- Dukung `@Environment(\.accessibilityReduceMotion)`:

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation? {
    reduceMotion ? nil : .easeInOut(duration: 0.3)
}
```
