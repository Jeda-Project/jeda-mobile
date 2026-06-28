# Anti-Pattern: Environment Injection

## The Trap

Accessing `EmotionClassificationService.shared` or any service singleton directly from a View.

## Why It Happens

Singletons are convenient. It's tempting to just reach for `.shared` from anywhere.

## Wrong Pattern

```swift
struct JedaJournalView: View {
    // ❌ Direct singleton access — couples View to concrete type, breaks testability
    private let service = EmotionClassificationService.shared

    var body: some View {
        Button("Classify") {
            Task { try await service.classify(text: input) }
        }
    }
}
```

## Right Pattern

```swift
// ✅ Depend on the protocol via @Environment
struct JedaJournalView: View {
    @Environment(\.emotionService) private var emotionService

    var body: some View {
        Button("Classify") {
            Task { try await emotionService.classify(text: input) }
        }
    }
}
```

## Choosing the Right Injection Mechanism

| Mechanism | When to Use |
|---|---|
| `@Environment` | Services, theme, locale — anything scoped to the environment tree |
| `@EnvironmentObject` | Observable shared state that many Views need to read/write |
| Constructor injection | Non-View types (Services, Repositories) — inject via `init` |
| `@State` / `@StateObject` | Local, owned state that does not need sharing |

## Rule

AGENTS.md Rule 5: every service must be accessed via `@Environment`, never via `.shared` from a View. See also Rule 6 — services must have a protocol so Views depend on the abstraction, not the concrete type.

## Impact

- Direct `.shared` access makes Views impossible to unit-test (cannot swap with a mock).
- Tight coupling means changing the service implementation breaks unrelated Views.
- Actor isolation violations can occur when main-thread Views touch non-isolated singletons.
