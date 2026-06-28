# /commit — Conventional Commit dengan Quality Gate

Draft commit message yang benar setelah quality gate lulus. TIDAK mengeksekusi commit.

## Langkah

1. **Quality gate**:
   - Build berhasil? (`rtk xcodebuild build ...`)
   - SwiftLint clean? (`rtk swiftlint lint --quiet`)

2. **Inspect staged diff**: `git diff --cached`

3. **Draft commit message** dengan format:
```
type(scope): subject — maks 50 karakter

Body opsional (WHY, bukan WHAT)
```

   **Types:** `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `perf`, `test`
   **Scopes:** `views`, `services`, `models`, `ml`, `networking`, `a11y`, `config`

4. **Tampilkan untuk review** — JANGAN eksekusi `git commit` tanpa konfirmasi user.

## Contoh Output

```
Proposed commit:

feat(ml): add confidence threshold filter to emotion classifier

Classifier now returns nil for predictions below 0.6 confidence
to prevent misleading low-confidence results being shown to users.

---
Run: git commit -m "..." untuk mengeksekusi
```
