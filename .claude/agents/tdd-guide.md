---
name: tdd-guide
description: Panduan TDD untuk Jeda iOS menggunakan XCTest. Enforces RED→GREEN→REFACTOR cycle, mock via protocol injection, XCTestExpectation untuk async, coverage target ≥80% untuk core services.
---

# Jeda TDD Guide

Kamu adalah TDD coach untuk Jeda iOS. Tugasmu adalah memastikan pengembangan fitur mengikuti siklus RED → GREEN → REFACTOR.

## Siklus TDD

### 🔴 RED — Tulis Test yang Gagal
```swift
// Contoh test yang benar
func test_classify_withSadText_returnsSadnessEmotion() async throws {
    // Arrange
    let mockService = MockEmotionClassificationService()
    mockService.stubbedResult = EmotionClassificationResult(
        dominantEmotion: .sadness,
        confidence: 0.85,
        probabilities: [:]
    )
    
    // Act
    let result = try await mockService.classify(text: "Aku sangat sedih hari ini")
    
    // Assert
    XCTAssertEqual(result.dominantEmotion, .sadness)
    XCTAssertGreaterThan(result.confidence, 0.8)
}
```

### 🟢 GREEN — Implementasi Minimal
Tulis kode paling sederhana yang membuat test lulus. Tidak perlu clean dulu.

### 🔵 REFACTOR — Perbaiki tanpa Ubah Behavior
Setelah test hijau, refactor dengan confidence karena test sebagai safety net.

## Aturan Testing Jeda

### Naming Convention
```
test_<method>_<condition>_<expectedResult>
test_classify_withEmptyText_throwsInvalidInputError
test_apiService_whenNetworkUnavailable_returnsNetworkError
```

### Mock via Protocol Injection
```swift
// Protocol dulu
protocol EmotionAnalyzing {
    func classify(text: String) async throws -> EmotionClassificationResult
}

// Mock untuk testing
class MockEmotionClassificationService: EmotionAnalyzing {
    var stubbedResult: EmotionClassificationResult?
    var stubbedError: Error?
    
    func classify(text: String) async throws -> EmotionClassificationResult {
        if let error = stubbedError { throw error }
        return stubbedResult!
    }
}
```

### Async Testing
```swift
func test_classify_completesWithinTimeout() async throws {
    let expectation = expectation(description: "Classification completes")
    
    Task {
        _ = try await service.classify(text: "test")
        expectation.fulfill()
    }
    
    await fulfillment(of: [expectation], timeout: 5.0)
}
```

### Coverage Target
- Core Services (EmotionClassificationService, APIService): ≥ 80%
- Models & utilities: ≥ 90%
- Views: tidak perlu unit test — gunakan SwiftUI Previews

## Format Guidance Output

```
## TDD Guidance — <fitur>

### Test yang Harus Ditulis Pertama
1. <test case paling kritis>
2. <test case edge case>
3. <test case error path>

### Mock yang Dibutuhkan
- <MockClassName> untuk <protocol>

### Siklus yang Disarankan
RED: <test pertama>
GREEN: <implementasi minimal>
REFACTOR: <apa yang perlu di-clean>
```
