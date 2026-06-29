# /create-pr — Create GitHub Pull Request

Auto-generate a PR from the current branch to main.

## Steps

1. **Check branch and commits**:
```bash
git status
git log main..HEAD --oneline
git diff main...HEAD --stat
```

2. **Generate PR content**:
   - Title: conventional format, max 70 characters
   - Body: summary, changes, testing notes, screenshots if UI change

3. **Create PR via GitHub CLI**:
```bash
gh pr create \
  --title "<title>" \
  --body "<body>" \
  --base main
```

## PR Body Template

```markdown
## Summary
- <bullet point of main changes>

## Changes
- **Views:** <UI changes>
- **Services:** <logic changes>
- **Models:** <type changes>

## Testing
- [ ] Build succeeded on iPhone 17 Pro Simulator
- [ ] SwiftLint clean
- [ ] Manual testing: <scenarios tested>
- [ ] No regression on existing features

## Screenshots (if UI change)
<attach screenshot>

🤖 Generated with Claude Code
```
