//
//  ChatCompletionAPIEndpoint.swift
//  Jeda
//
//  OpenAI chat completions API.
//

import Foundation

enum ChatCompletionAPIEndpoint: APIEndpoint {
    case complete(ChatCompletionRequest)

    var path: String {
        switch self {
        case .complete:
            return "chat/completions"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        switch self {
        case .complete(let request):
            return try? encodeBody(request)
        }
    }
}
