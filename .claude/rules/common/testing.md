# Testing Guidelines

## Coverage Target

| Layer | Target | Tool |
|-------|--------|------|
| Services (EmotionClassificationService, APIService) | ≥ 80% | XCTest |
| Models & utilities | ≥ 90% | XCTest |
| Views | No unit tests needed | SwiftUI Previews |

## Test Naming Convention

```swift
func test_<method>_<condition>_<expectedResult>()

// Examples:
func test_classify_withSadText_returnsSadnessEmotion()
func test_classify_withEmptyText_throwsInvalidInputError()
func test_apiService_whenNetworkUnavailable_returnsNetworkError()
func test_tokenizer_withMaxLength_truncatesCorrectly()
```

## Test Structure (AAA)

```swift
func test_classify_withSadText_returnsSadnessEmotion() async throws {
    // Arrange
    let mockService = MockEmotionClassificationService()
    mockService.stubbedResult = .init(dominantEmotion: .sadness, confidence: 0.9, probabilities: [:])

    // Act
    let result = try await mockService.classify(text: "Aku sangat sedih")

    // Assert
    XCTAssertEqual(result.dominantEmotion, .sadness)
    XCTAssertGreaterThan(result.confidence, 0.8)
}
```

## Mock via Protocol Injection

**DO NOT** subclass for mocking — use a protocol:

```swift
// Protocol
protocol EmotionAnalyzing {
    func classify(text: String) async throws -> EmotionClassificationResult
}

// Production
actor EmotionClassificationService: EmotionAnalyzing { ... }

// Mock for tests
final class MockEmotionClassificationService: EmotionAnalyzing {
    var stubbedResult: EmotionClassificationResult?
    var stubbedError: Error?
    var classifyCallCount = 0

    func classify(text: String) async throws -> EmotionClassificationResult {
        classifyCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedResult!
    }
}
```

## Async Testing

```swift
// ✅ Use async throws tests
func test_classify_completesSuccessfully() async throws {
    let result = try await service.classify(text: "test")
    XCTAssertNotNil(result)
}

// For callback-based code not yet converted to async
func test_someCallback_completesWithinTimeout() {
    let expectation = expectation(description: "completes")
    // ... fulfill expectation
    wait(for: [expectation], timeout: 5.0)
}
```

## What Needs to Be Tested

- ✅ Service business logic (classification, networking, parsing)
- ✅ Model transformations (Codable, computed properties)
- ✅ Error paths (network error, model error, invalid input)
- ✅ Edge cases (empty string, very long text, unicode characters)
- ❌ SwiftUI View rendering (use Previews)
- ❌ Third-party SDK internals (Firebase, Core ML model itself)
