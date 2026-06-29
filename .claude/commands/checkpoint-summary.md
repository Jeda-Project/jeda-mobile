---
description: Generate a session summary of changes, decisions, and tasks for efficient handovers.
---

<!-- Command: /checkpoint-summary [domain] -->
<!-- Run every 90min or every 10 tasks -->

# /checkpoint-summary — Session Summary

1. COLLECT: files modified (`git status`), tasks completed, decisions made, issues encountered
2. ACTIVE SUMMARY (≤300 tokens): print for the user
   - Branch, what was worked on, key decisions, files changed, next steps
3. FULL LOG: save to `.claude/session-logs/[YYYY-MM-DD]-[domain].md`
4. PROPAGATE: offer to add any new anti-patterns discovered to `.claude/anti-patterns/`
