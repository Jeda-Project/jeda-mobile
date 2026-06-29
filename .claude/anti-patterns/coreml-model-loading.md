# Anti-Pattern: Core ML Model Loading

## Problem

Loading a Core ML model the wrong way causes: UI freezes, crashes on launch, or the model not being found.

---

## 1. Do Not Load the Model on the Main Thread

### ❌ Anti-Pattern

```swift
// In AppDelegate or @main — blocks the UI on launch
@main
struct JedaApp: App {
    init() {
        // ❌ Synchronous model loading on main thread = UI freeze
        let model = try! MLModel(contentsOf: modelURL)
    }
}
```

### ✅ Load in a Background Actor

```swift
actor EmotionClassificationService {
    static let shared = EmotionClassificationService()
    private var model: JedaEmotionIndoBERT_int8?

    // ✅ Lazy loading on first use, not at launch
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
        config.computeUnits = .cpuAndNeuralEngine  // Optimal for iPhone

        let loaded = try JedaEmotionIndoBERT_int8(contentsOf: modelURL, configuration: config)
        self.model = loaded
        return loaded
    }
}
```

---

## 2. Correct Bundle Path Lookup

### ❌ Anti-Pattern

```swift
// ❌ Hardcoded path — will not work on device or TestFlight
let modelURL = URL(fileURLWithPath: "/path/to/JedaEmotionIndoBERT-int8.mlmodelc")

// ❌ Without subdirectory — model lives in Resources/Models/
let modelURL = Bundle.main.url(forResource: "JedaEmotionIndoBERT-int8", withExtension: "mlmodelc")
```

### ✅ Correct Lookup

```swift
// ✅ Xcode compiles .mlpackage → .mlmodelc automatically
// Source file is at: Resources/Models/JedaEmotionIndoBERT-int8.mlpackage
// Compiled output is: JedaEmotionIndoBERT-int8.mlmodelc (in the app bundle)

guard let modelURL = Bundle.main.url(
    forResource: "JedaEmotionIndoBERT-int8",
    withExtension: "mlmodelc"
) else {
    throw EmotionClassificationError.modelNotFound
}
```

> **Note:** Xcode automatically compiles `.mlpackage` to `.mlmodelc` at build time. In source code, reference the `.mlmodelc` extension (compiled), not `.mlpackage` (source).

---

## 3. Optimal MLModelConfiguration

### ❌ Anti-Pattern

```swift
// ❌ Default with no configuration = Xcode chooses, potentially suboptimal
let model = try JedaEmotionIndoBERT_int8(contentsOf: modelURL)

// ❌ CPU only — does not use the Neural Engine (slow)
let config = MLModelConfiguration()
config.computeUnits = .cpuOnly
```

### ✅ Optimal Configuration for IndoBERT-int8

```swift
let config = MLModelConfiguration()
config.computeUnits = .cpuAndNeuralEngine  // ✅ Use iPhone Neural Engine

// For int8 quantized models, the Neural Engine is very efficient
let model = try JedaEmotionIndoBERT_int8(contentsOf: modelURL, configuration: config)
```

---

## 4. Correct Singleton Actor Pattern

### ✅ Full Pattern

```swift
actor EmotionClassificationService: EmotionAnalyzing {
    static let shared = EmotionClassificationService()
    private init() {}  // Prevent direct instantiation

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
