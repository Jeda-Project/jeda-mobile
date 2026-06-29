/**
 * Scope: HTTPMethod.swift
 * Purpose: Enum of HTTP methods used when constructing API requests.
 */

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
