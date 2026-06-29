# Git Workflow

## Branch Strategy

```
main          → Production (TestFlight / App Store)
develop       → Active development
feature/*     → New features (from develop)
fix/*         → Bug fixes (from develop or main for hotfixes)
```

## Commit Format

```
type(scope): subject — max 50 characters

Optional body: explain WHY, not WHAT
```

**Types:**
| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Refactor without behavior change |
| `chore` | Dependency update, config, CI |
| `docs` | Documentation only |
| `style` | Format, rename (no logic change) |
| `perf` | Performance optimization |
| `test` | Add or fix tests |

**Scopes for Jeda:**
`views`, `services`, `models`, `ml`, `networking`, `a11y`, `config`, `ci`

**Examples:**
```
feat(ml): add confidence threshold filter to classifier
fix(views): correct touch target size on MoodPicker
refactor(services): extract tokenizer into dedicated actor
chore(ci): update Xcode version in ios-ci.yml
```

## Rules

- **DO NOT** push directly to `main` — always via PR
- **DO NOT** force push to a branch that already has a PR open
- One commit = one logical change
- `git commit --amend` only for commits that have not been pushed
- Use `/checkpoint` for safety commits during experiments

## Pull Request

- Title follows the commit message format
- Body uses the template from `/create-pr`
- PR must pass CI before merging
- Minimum 1 reviewer before merging to `main`
- Squash merge for feature branches to keep history clean
