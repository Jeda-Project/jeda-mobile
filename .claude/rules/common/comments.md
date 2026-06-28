# Code Comments

## Language

All comments must be written in **English**. No Indonesian.

## Top-of-File Docblock (REQUIRED on every source file)

Every `.swift` source file must start with a docblock in this exact format:

```swift
/**
 * Scope: FileName.swift
 * Purpose: one sentence describing what this file does.
 */
```

- `Scope` — the filename (basename only, with extension)
- `Purpose` — one sentence; describes the file's responsibility, not its implementation
- Closing tag: `*/` (standard — never `**/`)
- Place it before all imports, above the first symbol

## Inline Comments — Prohibited

Do **not** use `//` inline comments anywhere in source files.

Let well-named identifiers, types, and the top-of-file docblock carry the meaning.
If you feel the urge to write an inline comment, it is a signal to:
- Rename the variable/function to be more descriptive, or
- Extract the logic into a named function

**The only exception** is a non-obvious constraint that cannot be expressed in code
(e.g. a Core ML thread constraint, a SwiftUI rendering invariant, a PRD cross-reference).
Even then, keep it to one line and prefer it at the top-of-file docblock level instead.

## View Files — No Comments at All

Files matching `*View.swift` (SwiftUI screens and components) must contain zero comments.
The SwiftUI DSL and well-named modifiers carry all the documentation for views.
