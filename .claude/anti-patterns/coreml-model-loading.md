# Anti-Pattern: Core ML Model Loading

## Masalah

Memuat Core ML model dengan cara yang salah menyebabkan: UI freeze, crash saat launch, atau model yang tidak bisa ditemukan.

---

## 1. Jangan Load Model di Main Thread

### ❌ Anti-Pattern

```swift
// Di AppDelegate atau @main — memblokir UI launch
@main
struct JedaApp: App {
    init() {
        // ❌ Model loading sinkron di main thread = UI freeze
        let model = try! MLModel(contentsOf: modelURL)
    }
}
```

### ✅ Load di Background Actor

```swift
actor EmotionClassificationService {
    static let shared = EmotionClassificationService()
    private var model: JedaEmotionIndoBERT_int8?

    // ✅ Lazy loading saat pertama kali digunakan, bukan saat launch
    private func loadModelIfNeeded() throws -> JedaEmotionIndoBERT_int8 {
        if let model = model { return model }

        guard let modelURL = Bundle.main.url(
            forResource: "JedaEmotionIndoBERT-int8",
            withExtension: "mlmodelc",
            subdirectory: "Models"
        ) else {
            throw EmotionClassificationError.modelNotFound
        }

        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine  // Optimal untuk iPhone

        let loaded = try JedaEmotionIndoBERT_int8(contentsOf: modelURL, configuration: config)
        self.model = loaded
        return loaded
    }
}
```

---

## 2. Bundle Path Lookup yang Benar

### ❌ Anti-Pattern

```swift
// ❌ Path hardcoded — tidak akan bekerja di device atau TestFlight
let modelURL = URL(fileURLWithPath: "/path/to/JedaEmotionIndoBERT-int8.mlmodelc")

// ❌ Tanpa subdirectory — model ada di Resources/Models/
let modelURL = Bundle.main.url(forResource: "JedaEmotionIndoBERT-int8", withExtension: "mlmodelc")
```

### ✅ Lookup yang Benar

```swift
// ✅ Xcode compile .mlpackage → .mlmodelc otomatis
// File ada di: Resources/Models/JedaEmotionIndoBERT-int8.mlpackage (source)
// Compiled jadi: JedaEmotionIndoBERT-int8.mlmodelc (di app bundle)

guard let modelURL = Bundle.main.url(
    forResource: "JedaEmotionIndoBERT-int8",
    withExtension: "mlmodelc"
) else {
    throw EmotionClassificationError.modelNotFound
}
```

> **Catatan:** Xcode otomatis mengompilasi `.mlpackage` menjadi `.mlmodelc` saat build. Di source code, referensikan ekstensi `.mlmodelc` (compiled), bukan `.mlpackage` (source).

---

## 3. MLModelConfiguration yang Optimal

### ❌ Anti-Pattern

```swift
// ❌ Default tanpa konfigurasi = Xcode memilih, mungkin suboptimal
let model = try JedaEmotionIndoBERT_int8(contentsOf: modelURL)

// ❌ CPU only — tidak memanfaatkan Neural Engine (lambat)
let config = MLModelConfiguration()
config.computeUnits = .cpuOnly
```

### ✅ Konfigurasi Optimal untuk IndoBERT-int8

```swift
let config = MLModelConfiguration()
config.computeUnits = .cpuAndNeuralEngine  // ✅ Manfaatkan Neural Engine iPhone

// Untuk int8 quantized model, Neural Engine sangat efisien
let model = try JedaEmotionIndoBERT_int8(contentsOf: modelURL, configuration: config)
```

---

## 4. Singleton Actor Pattern yang Benar

### ✅ Pattern Lengkap

```swift
actor EmotionClassificationService: EmotionAnalyzing {
    static let shared = EmotionClassificationService()
    private init() {}  // Cegah instantiasi langsung

    private var model: JedaEmotionIndoBERT_int8?

    func classify(text: String) async throws -> EmotionClassificationResult {
        let model = try loadModelIfNeeded()
        // ... inference logic
    }

    private func loadModelIfNeeded() throws -> JedaEmotionIndoBERT_int8 {
        if let existing = model { return existing }

        guard let url = Bundle.main.url(
            forResource: "JedaEmotionIndoBERT-int8",
            withExtension: "mlmodelc"
        ) else { throw EmotionClassificationError.modelNotFound }

        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine

        let loaded = try JedaEmotionIndoBERT_int8(contentsOf: url, configuration: config)
        self.model = loaded
        return loaded
    }
}
```
