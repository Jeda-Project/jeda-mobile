# Anti-Pattern: swiftformat Rules That Conflict with SwiftLint

## Problem

When swiftformat runs (via hook or CLI), certain default rules actively revert fixes
made for SwiftLint compliance — creating an endless loop of violations.

## Conflicting Rules (as of swiftformat + SwiftLint 0.65.0)

| swiftformat rule | What it does | SwiftLint violation it causes |
|---|---|---|
| `wrapFunctionBodies` | Expands `{ singleStatement }` to multiline | `file_length` (150-line limit) |
| `wrapPropertyBodies` | Expands `var x: T { value }` to multiline | `file_length` (150-line limit) |
| `modifierOrder` | Reorders to `private nonisolated` | `modifier_order` (wants `nonisolated` first) |
| `blankLinesBetweenScopes` | Inserts blank lines between methods | `file_length` (150-line limit) |
| `wrapMultilineStatementBraces` | Moves `{` to its own line after multi-line conditions | `opening_brace` (brace must be on same line) |

## Fix

Add to `.swiftformat`:

```
--disable wrapFunctionBodies
--disable wrapPropertyBodies
--disable modifierOrder
--disable blankLinesBetweenScopes
--disable wrapMultilineStatementBraces
```

These are already present in Jeda's `.swiftformat`. Do not remove them.

## Why Not Fix SwiftLint Instead?

- `file_length` threshold is intentionally strict (warning=error=150) — enforces small files
- `modifier_order` with `nonisolated` first matches Swift evolution conventions
- `opening_brace` same-line brace is standard Swift style (K&R, not Allman)

Changing SwiftLint thresholds to accommodate swiftformat would hide real code quality issues.
