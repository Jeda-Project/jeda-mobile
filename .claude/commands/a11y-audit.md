# /a11y-audit [path] — Accessibility Audit

Audit SwiftUI views for accessibility to ensure VoiceOver, Dynamic Type, and HIG compliance.

## Usage
```
/a11y-audit                          # audit all Views/
/a11y-audit Jeda/Views/JedaMoodPicker.swift
```

## Steps

1. **Scan the specified Swift file** (or all files in `Views/` if no path is given)
2. **Use the `jeda-a11y-guard` agent** for a thorough audit
3. Check specifically for:
   - `.accessibilityLabel` on all buttons and icons
   - No `.font(.system(size:))` — Dynamic Type violation
   - Touch target minimum 44×44 pt
   - VoiceOver grouping with `.accessibilityElement(children:)`
   - Animations that support `accessibilityReduceMotion`

## Output

Report with priorities:
- 🚫 Critical violations (block commit)
- ⚠️ Needs improvement
- ✅ Already accessible
