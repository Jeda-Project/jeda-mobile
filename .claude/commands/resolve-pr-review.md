# /resolve-pr-review — Address PR Review Comments

Address and respond to review comments on a pull request.

## Steps

1. Use GitHub MCP `get_pull_request_comments` to fetch all review comments
2. Group by severity: CRITICAL → HIGH → MEDIUM → LOW
3. Resolve CRITICAL and HIGH first — these are blocking merge
4. For each comment:
   a. Understand the root cause (not just the symptom)
   b. Apply the minimal fix
   c. Run the relevant gate (build check for compiler errors, test for logic)
   d. Stage and commit the fix with a descriptive message
5. After all fixes: run full build + SwiftLint
6. Push the updated branch
7. Use GitHub MCP `add_issue_comment` or resolve the thread to signal it has been addressed

## Response Convention

When replying to a review thread:
- Acknowledge the finding briefly
- Explain what was changed and why
- If you disagree: explain your rationale, do not just ignore it

## Notes

- Fix the root cause — do not patch over it just to silence the reviewer
- One commit per logical fix; do not squash everything into one "address review comments"
- If a MEDIUM/LOW comment requires significant refactoring: create a follow-up issue rather than scope-creeping the PR
