# Session Log: nonisolated static method fixes

**Date:** 2026-06-29
**Branch:** develop

## Tasks Completed

1. Fixed `Emotion.swift` — `softmax(_:)` marked `nonisolated` to resolve "Call to main actor-isolated static method in nonisolated context" error
2. Fixed `AIService+WeeklySummary.swift` — `nonEmpty(_:)` marked `nonisolated` for same reason
3. Diagnosed stale Xcode warning in `IndoBertTokenizer.swift` (line 74 `let chars`) — already correct, needed Clean Build Folder

## Root Cause

Static methods that are pure (no mutable shared state) inside a type with implicit `@MainActor` isolation get inferred as `@MainActor`. When called from a `nonisolated` context, the compiler errors. Fix: `private nonisolated static func`.

## Files Modified

- `Jeda/Models/Emotion.swift` — `softmax`
- `Jeda/Services/AI/AIService+WeeklySummary.swift` — `nonEmpty`
