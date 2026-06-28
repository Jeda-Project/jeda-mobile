# /create-pr — Buat GitHub Pull Request

Auto-generate PR dari branch saat ini ke main.

## Langkah

1. **Cek branch dan commits**:
```bash
git status
git log main..HEAD --oneline
git diff main...HEAD --stat
```

2. **Generate PR content**:
   - Title: conventional format, maks 70 karakter
   - Body: summary, changes, testing notes, screenshots jika UI change

3. **Buat PR via GitHub CLI**:
```bash
gh pr create \
  --title "<title>" \
  --body "<body>" \
  --base main
```

## Template PR Body

```markdown
## Summary
- <bullet point perubahan utama>

## Changes
- **Views:** <perubahan UI>
- **Services:** <perubahan logic>
- **Models:** <perubahan types>

## Testing
- [ ] Build berhasil di iPhone 16 Simulator
- [ ] SwiftLint clean
- [ ] Manual testing: <skenario yang di-test>
- [ ] Tidak ada regresi pada fitur yang ada

## Screenshots (jika UI change)
<lampirkan screenshot>

🤖 Generated with Claude Code
```
