# Coding Style — Common

## Immutability

ALWAYS use value types (`struct`, `enum`) for domain models. Avoid mutation where copy-on-write can be used instead:

```swift
// ✅ Correct — immutable update
var updated = entry
updated.mood = .happy

// ❌ Wrong — mutation in place without control
entry.mood = .happy  // direct mutation on a shared reference
```

Rationale: `struct` in Swift is a value type — safe for concurrency and easy to test.

## Core Principles

### KISS
- Choose the simplest solution that actually works
- Avoid premature abstraction — three similar Views do not immediately need to be extracted
- Optimize for readability, not cleverness

### DRY
- Extract logic that is genuinely repeated into `ViewModifier`, extension, or utility
- Do not copy-paste styling — create `JedaButtonStyle` or a custom `ViewModifier`
- Abstract only when repetition is real, not speculative

### YAGNI
- Do not create protocols/abstractions before there are two implementations
- Start simple with `struct`, move to `class`/`actor` only when needed
- Do not add "hooks for future features" that are not confirmed

## File Organization

MANY SMALL FILES > FEW LARGE FILES:

- One file = one primary type (one View, one Service, one Model)
- Max ~150 lines per file — if more, consider splitting
- Organize by feature, not by type:
  ```
  // ✅ By feature
  Journal/JournalEntry.swift
  Journal/JournalService.swift
  Journal/JournalListView.swift

  // ❌ By type (hard to navigate)
  Models/JournalEntry.swift
  Services/JournalService.swift
  Views/JournalListView.swift
  ```

## Error Handling

ALWAYS handle errors explicitly:

- `throws` functions: handle or propagate, do not use `try?` unless failure is truly acceptable
- User-facing error messages in **Indonesian** (matching Jeda's target users)
- Log errors to console in debug, to analytics in production
- Do not swallow errors with `catch {}`

## Input Validation

Validate at system boundaries:
- Validate user input before sending to a Service
- Do not trust data from network responses — decode with `Codable` + error handling
- Empty journal text must be handled before sending to ML inference

## Code Smells to Avoid

### Deep Nesting
Use early return / guard:
```swift
// ❌ Deep nesting
func process() {
    if isValid {
        if hasData {
            if !isEmpty {
                // logic
            }
        }
    }
}

// ✅ Early return
func process() {
    guard isValid else { return }
    guard hasData else { return }
    guard !isEmpty else { return }
    // logic
}
```

### Magic Numbers
```swift
// ❌
.frame(minWidth: 44, minHeight: 44)

// ✅
.frame(minWidth: JedaSpacing.touchTarget, minHeight: JedaSpacing.touchTarget)
```

### Long Functions
Break long functions into private helpers with clear names.
