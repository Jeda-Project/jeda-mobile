/**
 * Scope: JedaAIConstants.swift
 * Purpose: Shared constants for AI service configuration including model names and system prompts.
 */

import Foundation

enum JedaAIConstants {
    static let aiModel = "nvidia/nemotron-3-ultra-550b-a55b:free"
    static let fastAIModel = "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free"

    static var baseURL: URL {
        URL(string: "https://openrouter.ai/api/v1/")!
    }
}
