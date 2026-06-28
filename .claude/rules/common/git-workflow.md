# Git Workflow

## Branch Strategy

```
main          → Production (TestFlight / App Store)
develop       → Active development
feature/*     → Fitur baru (dari develop)
fix/*         → Bug fix (dari develop atau main untuk hotfix)
```

## Commit Format

```
type(scope): subject — maks 50 karakter

Body opsional: jelaskan WHY, bukan WHAT
```

**Types:**
| Type | Kapan |
|------|-------|
| `feat` | Fitur baru |
| `fix` | Bug fix |
| `refactor` | Refactor tanpa perubahan behavior |
| `chore` | Update dependency, config, CI |
| `docs` | Dokumentasi saja |
| `style` | Format, rename (tidak ada logic change) |
| `perf` | Optimasi performance |
| `test` | Tambah atau fix test |

**Scopes untuk Jeda:**
`views`, `services`, `models`, `ml`, `networking`, `a11y`, `config`, `ci`

**Contoh:**
```
feat(ml): add confidence threshold filter to classifier
fix(views): correct touch target size on MoodPicker
refactor(services): extract tokenizer into dedicated actor
chore(ci): update Xcode version in ios-ci.yml
```

## Aturan

- **JANGAN** push langsung ke `main` — selalu via PR
- **JANGAN** force push ke branch yang sudah di-PR
- Satu commit = satu logical change
- `git commit --amend` hanya untuk commit yang belum di-push
- Gunakan `/checkpoint` untuk safety commit saat eksperimen

## Pull Request

- Title mengikuti format commit message
- Body menggunakan template dari `/create-pr`
- PR harus lulus CI sebelum merge
- Minimum 1 reviewer sebelum merge ke `main`
- Squash merge untuk feature branches agar history bersih
