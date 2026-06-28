# /resolve-pr-review — Address PR Review Comments

Tangani dan respond review comment pada pull request.

## Langkah

1. Gunakan GitHub MCP `get_pull_request_comments` untuk fetch semua review comments
2. Kelompokkan berdasarkan severity: CRITICAL → HIGH → MEDIUM → LOW
3. Selesaikan CRITICAL dan HIGH terlebih dahulu — ini yang memblokir merge
4. Untuk setiap comment:
   a. Pahami root cause (bukan hanya symptom)
   b. Terapkan fix minimal
   c. Jalankan gate yang relevan (build check untuk compiler error, test untuk logic)
   d. Stage dan commit fix dengan pesan deskriptif
5. Setelah semua fix: jalankan full build + SwiftLint
6. Push updated branch
7. Gunakan GitHub MCP `add_issue_comment` atau resolve thread untuk sinyal sudah ditangani

## Konvensi Response

Saat membalas review thread:
- Acknowledge temuan secara singkat
- Jelaskan apa yang diubah dan mengapa
- Jika tidak setuju: jelaskan rationale, jangan abaikan begitu saja

## Catatan

- Fix root cause — jangan patch over untuk menyilencing reviewer
- Satu commit per logical fix; jangan squash semua jadi satu "address review comments"
- Jika comment MEDIUM/LOW butuh refactoring signifikan: buat follow-up issue daripada scope-creeping PR
