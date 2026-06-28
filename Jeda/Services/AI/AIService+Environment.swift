//
//  AIService+Environment.swift
//  Jeda
//

import SwiftUI

private struct AICompletingKey: EnvironmentKey {
    static let defaultValue: (any AICompleting)? = nil
}

extension EnvironmentValues {
    var aiService: (any AICompleting)? {
        get { self[AICompletingKey.self] }
        set { self[AICompletingKey.self] = newValue }
    }
}
