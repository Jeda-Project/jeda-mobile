# /review — Senior iOS Code Review

Lakukan code review menyeluruh pada staged changes atau file yang ditentukan.

## Langkah

1. **Cek staged diff**: `git diff --cached`
2. **Build check**: pastikan project masih bisa di-build
3. **Gunakan agent `code-reviewer`** untuk review:
   - AGENTS.md compliance (15 Golden Rules)
   - SoC violations (business logic di View, SwiftUI di Service)
   - Swift concurrency correctness
   - Memory management
   - Accessibility
   - Error handling
4. **Gunakan agent `jeda-ui-reviewer`** jika ada perubahan di `Views/`
5. **Gunakan agent `jeda-security-guard`** jika ada perubahan di Services atau config

## Output

Laporan terstruktur dengan verdict: **APPROVE / WARNING / BLOCK**

Jika BLOCK, jelaskan apa yang harus diperbaiki sebelum commit.
