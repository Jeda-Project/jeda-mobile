# Swift Patterns

## Protocol-Oriented Design

Every Service MUST have a protocol:

```swift
// 1. Define the protocol in Models/ or a separate file
protocol EmotionAnalyzing {
    func classify(text: String) async throws -> EmotionClassificationResult
}

// 2. Implement in Services/
actor EmotionClassificationService: EmotionAnalyzing {
    func classify(text: String) async throws -> EmotionClassificationResult { ... }
}

// 3. Inject via protocol, not concrete type
struct JournalView: View {
    @Environment(\.emotionService) private var service: any EmotionAnalyzing
}
```

## Result Type for Error Propagation

For operations whose result needs to be passed to another layer without throwing:

```swift
// When async throws cannot be used directly
func classifyAsync(text: String, completion: @escaping (Result<EmotionClassificationResult, Error>) -> Void) {
    Task {
        do {
            let result = try await classify(text: text)
            completion(.success(result))
        } catch {
            completion(.failure(error))
        }
    }
}
```

## Singleton Pattern (Services Only)

```swift
actor EmotionClassificationService {
    static let shared = EmotionClassificationService()
    private init() {}  // prevent direct instantiation
}
```

> Singletons are ONLY for Services. Do not create singletons for Views or Models.

## Environment Injection Pattern

```swift
// 1. Define an EnvironmentKey
private struct EmotionServiceKey: EnvironmentKey {
    static let defaultValue: any EmotionAnalyzing = EmotionClassificationService.shared
}

// 2. Extend EnvironmentValues
extension EnvironmentValues {
    var emotionService: any EmotionAnalyzing {
        get { self[EmotionServiceKey.self] }
        set { self[EmotionServiceKey.self] = newValue }
    }
}

// 3. Inject at the App root
@main
struct JedaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.emotionService, EmotionClassificationService.shared)
        }
    }
}

// 4. Use in a View
struct SomeView: View {
    @Environment(\.emotionService) private var emotionService
}
```

## Codable for Network Models

```swift
struct EmotionAPIResponse: Codable {
    let emotion: String
    let confidence: Double
    let timestamp: Date

    // Use CodingKeys if the names differ from JSON
    enum CodingKeys: String, CodingKey {
        case emotion
        case confidence
        case timestamp = "created_at"
    }
}
```

## Error Types

```swift
enum EmotionClassificationError: LocalizedError {
    case modelNotFound
    case invalidInput(String)
    case inferenceFailed(Error)

    // errorDescription in Indonesian (for user-facing messages)
    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "Model klasifikasi tidak ditemukan. Coba install ulang aplikasi."
        case .invalidInput(let reason):
            return "Teks tidak valid: \(reason)"
        case .inferenceFailed:
            return "Klasifikasi gagal. Coba lagi."
        }
    }
}
```
