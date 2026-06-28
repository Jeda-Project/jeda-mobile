//
//  JedaAIConstants.swift
//  Jeda
//

import Foundation

enum JedaAIConstants {
    static let aiEndpoint = "https://api.openai.com/v1/chat/completions"
    static let aiModel = "gpt-4o-mini"

    static var baseURL: URL {
        URL(string: "https://api.openai.com/v1/")!
    }
}
