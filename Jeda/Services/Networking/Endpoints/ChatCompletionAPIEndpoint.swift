/**
 * Scope: ChatCompletionAPIEndpoint.swift
 * Purpose: Endpoint descriptor for the OpenAI-compatible chat completion API route.
 */

import Foundation

enum ChatCompletionAPIEndpoint: APIEndpoint {
    case complete(ChatCompletionRequest)

    var path: String {
        switch self {
        case .complete:
            "chat/completions"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        switch self {
        case let .complete(request):
            try? encodeBody(request)
        }
    }
}
