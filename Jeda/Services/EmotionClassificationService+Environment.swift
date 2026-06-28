//
//  EmotionClassificationService+Environment.swift
//  Jeda
//

import SwiftUI

private struct EmotionAnalyzingKey: EnvironmentKey {
    static let defaultValue: any EmotionAnalyzing = EmotionClassificationService.shared
}

extension EnvironmentValues {
    var emotionService: any EmotionAnalyzing {
        get { self[EmotionAnalyzingKey.self] }
        set { self[EmotionAnalyzingKey.self] = newValue }
    }
}
