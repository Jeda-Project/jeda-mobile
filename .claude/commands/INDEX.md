# Commands Index

> Invoke with `/command-name` in the Claude Code CLI.

---

## Planning

| Command | When to Use |
|---------|-------------|
| `/plan` | Before a new feature — breakdown per layer (Models → Services → Views), risk assessment |

---

## Code Review

| Command | When to Use |
|---------|-------------|
| `/review` | Thorough review of staged changes (SoC, AGENTS.md compliance, a11y, Swift best practices) |
| `/a11y-audit [path]` | SwiftUI accessibility audit — VoiceOver, Dynamic Type, touch targets |

---

## Quality Gates

| Command | When to Use |
|---------|-------------|
| `/check-fix` | Build + SwiftLint; auto-fix what can be fixed, report PASS/FAIL |
| `/build-sim` | Build to iPhone 17 Pro Simulator, display clean output |
| `/test` | Run XCTest suite, report test count + failures |

---

## Git & Release

| Command | When to Use |
|---------|-------------|
| `/commit` | Quality gate → inspect diff → draft conventional commit message |
| `/create-pr` | Create a PR from the current branch with a standardized body |
| `/merge-pr` | Merge an approved PR via GitHub MCP |
| `/resolve-pr-review` | Address and respond to review comments |

---

## Session Management

| Command | When to Use |
|---------|-------------|
| `/checkpoint [desc]` | Safety commit mid-session with timestamp |
| `/checkpoint-summary [domain]` | Session summary for handover — save to session-logs/ |
| `/aside` | Pause the current task, handle a quick side fix, then return |
