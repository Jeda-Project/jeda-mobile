# iOS Accessibility

## Why Accessibility Matters for Jeda

Jeda is a mental health app. Users who need accessibility are often also the most vulnerable. An inaccessible app actively excludes them.

## VoiceOver

### accessibilityLabel
```swift
// ✅ Descriptive label
Button(action: saveEntry) {
    Image(systemName: "checkmark.circle.fill")
}
.accessibilityLabel("Simpan jurnal")

// ❌ No label — VoiceOver will only read the SF Symbol name
Button(action: saveEntry) {
    Image(systemName: "checkmark.circle.fill")
}
```

### accessibilityHint
Use to describe the RESULT of an action, not the action itself:
```swift
Button("Analisis Emosi") { classify() }
    .accessibilityHint("Menganalisis teks jurnal dan menampilkan emosi dominan")
```

### Grouping
```swift
// ✅ Group elements that should be read together
HStack {
    Image(systemName: emotion.systemImageName)
    Text(emotion.displayName)
    Text("\(Int(confidence * 100))%")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(emotion.displayName), keyakinan \(Int(confidence * 100)) persen")
```

### Decorative Elements
```swift
// ✅ Hide decorative elements from VoiceOver
Image(systemName: "leaf.fill")
    .accessibilityHidden(true)  // decorative only, no information

Divider()
    .accessibilityHidden(true)
```

## Dynamic Type

```swift
// ✅ Text styles that support Dynamic Type
Text("Catatan Hari Ini")
    .font(.headline)

// ✅ Adaptive layout — use VStack when text grows larger
@Environment(\.dynamicTypeSize) var typeSize

var isAccessibilitySize: Bool {
    typeSize >= .accessibility1
}

var body: some View {
    Group {
        if isAccessibilitySize {
            VStack { labelAndValue }
        } else {
            HStack { labelAndValue }
        }
    }
}

// ❌ Hardcoded size — does not follow Dynamic Type
Text("Catatan").font(.system(size: 17))
```

## Touch Targets

```swift
// ✅ Minimum 44×44 pt — important for users with motor impairments
Button("Hapus") { deleteEntry() }
    .frame(minWidth: 44, minHeight: 44)

// ✅ contentShape to expand hit area without changing visual size
Image(systemName: "trash")
    .frame(width: 24, height: 24)
    .contentShape(Rectangle().size(CGSize(width: 44, height: 44)))
    .onTapGesture { deleteEntry() }
```

## Color & Contrast

```swift
// ✅ Do not rely on color alone to convey information
HStack {
    Circle()
        .fill(emotionColor)
        .frame(width: 12, height: 12)
    Text(emotion.displayName)  // ✅ always include accompanying text
}

// ❌ Color alone without a label
Circle()
    .fill(emotionColor)  // colorblind users will not know what this means
```

## Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// ✅ Optional animation based on user preference
func animateIfAllowed(_ animation: Animation, body: () -> Void) {
    if reduceMotion {
        body()
    } else {
        withAnimation(animation) { body() }
    }
}
```
