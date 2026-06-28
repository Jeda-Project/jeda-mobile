# iOS Accessibility

## Mengapa Aksesibilitas Penting untuk Jeda

Jeda adalah aplikasi kesehatan mental. Pengguna yang membutuhkan aksesibilitas seringkali juga paling rentan secara mental. Aplikasi yang tidak aksesibel secara aktif mengeksklusi mereka.

## VoiceOver

### accessibilityLabel
```swift
// ✅ Label deskriptif
Button(action: saveEntry) {
    Image(systemName: "checkmark.circle.fill")
}
.accessibilityLabel("Simpan jurnal")

// ❌ Tidak ada label — VoiceOver hanya akan baca nama SF Symbol
Button(action: saveEntry) {
    Image(systemName: "checkmark.circle.fill")
}
```

### accessibilityHint
Gunakan untuk menjelaskan HASIL dari aksi, bukan aksi itu sendiri:
```swift
Button("Analisis Emosi") { classify() }
    .accessibilityHint("Menganalisis teks jurnal dan menampilkan emosi dominan")
```

### Grouping
```swift
// ✅ Kelompokkan elemen yang harus dibaca bersamaan
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
// ✅ Sembunyikan elemen dekoratif dari VoiceOver
Image(systemName: "leaf.fill")
    .accessibilityHidden(true)  // hanya dekorasi, tidak ada info

Divider()
    .accessibilityHidden(true)
```

## Dynamic Type

```swift
// ✅ Text styles yang support Dynamic Type
Text("Catatan Hari Ini")
    .font(.headline)

// ✅ Layout yang adaptif — gunakan VStack ketika teks membesar
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

// ❌ Hardcoded size — tidak ikut Dynamic Type
Text("Catatan").font(.system(size: 17))
```

## Touch Targets

```swift
// ✅ Minimum 44×44 pt — penting untuk pengguna motor impairment
Button("Hapus") { deleteEntry() }
    .frame(minWidth: 44, minHeight: 44)

// ✅ contentShape untuk expand hit area tanpa mengubah visual
Image(systemName: "trash")
    .frame(width: 24, height: 24)
    .contentShape(Rectangle().size(CGSize(width: 44, height: 44)))
    .onTapGesture { deleteEntry() }
```

## Color & Contrast

```swift
// ✅ Jangan hanya andalkan warna untuk menyampaikan informasi
HStack {
    Circle()
        .fill(emotionColor)
        .frame(width: 12, height: 12)
    Text(emotion.displayName)  // ✅ selalu ada teks pendamping
}

// ❌ Hanya warna tanpa label
Circle()
    .fill(emotionColor)  // user buta warna tidak tahu ini maksudnya apa
```

## Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// ✅ Animasi opsional berdasarkan preferensi user
func animateIfAllowed(_ animation: Animation, body: () -> Void) {
    if reduceMotion {
        body()
    } else {
        withAnimation(animation) { body() }
    }
}
```
