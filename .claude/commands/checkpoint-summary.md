---
description: Generate a session summary of changes, decisions, and tasks for efficient handovers.
---

<!-- Command: /checkpoint-summary [domain] -->
<!-- Run every 90min or every 10 tasks -->

# /checkpoint-summary — Session Summary

1. COLLECT: files modified (`git status`), tasks completed, decisions made, issues encountered
2. ACTIVE SUMMARY (≤300 tokens): print untuk user
   - Branch, apa yang dikerjakan, keputusan penting, files yang diubah, langkah selanjutnya
3. FULL LOG: simpan ke `.claude/session-logs/[YYYY-MM-DD]-[domain].md`
4. PROPAGATE: tawarkan untuk menambahkan anti-pattern baru yang ditemukan ke `.claude/anti-patterns/`
