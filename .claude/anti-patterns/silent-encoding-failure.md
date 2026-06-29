# Anti-Pattern: Silent Encoding Failure with `try?`

## Problem

Using `try?` when encoding a request body in a computed property causes the error
to disappear without a trace. The request is sent with a `nil` body, the server receives
an empty payload, and there is no log or crash indicating what went wrong.

```swift
// ❌ Encoding error is silently swallowed
var body: Data? {
    guard case let .create(request) = self else { return nil }
    return try? encodeBody(request)  // if it fails, nil — no log, no crash
}
```

**Real-world impact:** The backend receives a request without a body, returns 400/422, and
on the iOS side it only appears as a network error with no clue about the root cause.

## Fix

Use `do/catch` with `assertionFailure` to crash in debug builds, silent in release:

```swift
// ✅ Crash in debug, silent in release — root cause is visible during development
var body: Data? {
    guard case let .create(request) = self else { return nil }
    do {
        return try encodeBody(request)
    } catch {
        assertionFailure("EntriesAPIEndpoint: failed to encode request body — \(error)")
        return nil
    }
}
```

## When This Applies

Any computed `body: Data?` property in `APIEndpoint` implementations. The protocol
cannot `throws`, but that does not mean errors may be swallowed.

## Rules

- **Do not** use `try?` on encoding operations whose result is used as a
  network request body
- **Always** log or `assertionFailure` if you are forced to return a fallback from a catch block
- `try?` is only acceptable when failure is truly unimportant (e.g., optional
  cache read, analytics write)
