---
name: environment-key-no-published-observation
description: Custom EnvironmentKey does not observe @Published changes on ObservableObject — use @EnvironmentObject instead.
---

# Anti-Pattern: Custom EnvironmentKey Does Not Observe `@Published`

## Problem

If an `ObservableObject` (such as `ReflectionStore`) is injected via a custom `EnvironmentKey`, SwiftUI does **not** trigger a re-render when a `@Published` property changes.

```swift
// ❌ WRONG — UI does not update when store.entries changes
private struct ReflectionStoreKey: EnvironmentKey {
    static let defaultValue: ReflectionStore = ReflectionStore()
}

// In a View:
@Environment(\.reflectionStore) private var store: ReflectionStore
// store.entries changes → UI does NOT re-render
```

## Root Cause

`@Environment` only propagates a new value when the parent calls `.environment(\.key, newValue)` again. It does not subscribe to the `objectWillChange` publisher of an `ObservableObject`.

`@EnvironmentObject`, on the other hand, uses `objectWillChange` — every `@Published` property change automatically triggers a re-render in all Views observing it.

## Fix

```swift
// ✅ CORRECT — use @EnvironmentObject
// In JedaApp.swift:
ContentView()
    .environmentObject(reflectionStore)

// In a View:
@EnvironmentObject private var store: ReflectionStore
// store.entries changes → UI re-renders ✓
```

## When a Custom EnvironmentKey Is Still Fine

Use a custom `EnvironmentKey` for:
- Protocol types (`any EmotionAnalyzing`, `any EntryRepositing`) — no need to observe published changes
- Non-ObservableObject values (theme, locale, feature flags)
- Services injected via protocol (stateless or actor-based)

Use `@EnvironmentObject` for `ObservableObject`s whose Views need to react to state changes.

## Discovered

Session 2026-06-29: `ReflectionStore` was injected via a custom key. Pagination fetch succeeded (data entered the store), but the UI was stuck at 10 items because there was no re-render. Fix: migrate to `@EnvironmentObject`.
