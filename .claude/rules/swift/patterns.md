# Swift Patterns

## Protocol-Oriented Design

Setiap Service WAJIB punya protocol:

```swift
// 1. Definisikan protocol di Models/ atau di file terpisah
protocol EmotionAnalyzing {
    func classify(text: String) async throws -> EmotionClassificationResult
}

// 2. Implementasi di Services/
actor EmotionClassificationService: EmotionAnalyzing {
    func classify(text: String) async throws -> EmotionClassificationResult { ... }
}

// 3. Inject via protocol, bukan concrete type
struct JournalView: View {
    @Environment(\.emotionService) private var service: any EmotionAnalyzing
}
```

## Result Type untuk Error Propagation

Untuk operasi yang hasilnya perlu di-pass ke layer lain tanpa throwing:

```swift
// Ketika tidak bisa pakai async throws langsung
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

## Singleton Pattern (Hanya untuk Services)

```swift
actor EmotionClassificationService {
    static let shared = EmotionClassificationService()
    private init() {}  // cegah instantiasi langsung
}
```

> Singleton HANYA untuk Services. Jangan buat singleton untuk View atau Model.

## Environment Injection Pattern

```swift
// 1. Definisikan EnvironmentKey
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

// 3. Inject di App root
@main
struct JedaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.emotionService, EmotionClassificationService.shared)
        }
    }
}

// 4. Gunakan di View
struct SomeView: View {
    @Environment(\.emotionService) private var emotionService
}
```

## Codable untuk Network Models

```swift
struct EmotionAPIResponse: Codable {
    let emotion: String
    let confidence: Double
    let timestamp: Date

    // Gunakan CodingKeys jika nama berbeda dari JSON
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

    // errorDescription dalam Bahasa Indonesia (untuk user-facing)
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
