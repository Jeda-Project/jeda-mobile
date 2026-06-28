# /merge-pr — Merge Pull Request

Merge PR yang sudah diapprove.

## Pre-Merge Checklist

- [ ] PR sudah punya minimal 1 approval (atau self-review tanpa CRITICAL/HIGH)
- [ ] Semua CI checks hijau (ios-ci.yml lulus)
- [ ] Branch up-to-date dengan `main`
- [ ] Tidak ada review comment yang belum diselesaikan

## Langkah

1. Gunakan GitHub MCP `get_pull_request` untuk konfirmasi status PR dan reviews
2. Gunakan GitHub MCP `get_pull_request_status` untuk konfirmasi CI checks hijau
3. Jika branch ketinggalan `main`: gunakan GitHub MCP `update_pull_request_branch`
4. Gunakan GitHub MCP `merge_pull_request` dengan `merge_method: "squash"` (untuk feature branches)
5. Konfirmasi merge berhasil
6. Hapus feature branch lokal: `git branch -d <branch>`

## Setelah Merge

- Pull `main` lokal: `git checkout main && git pull origin main`
- Jika ada perubahan pada Core ML model: pastikan `.mlpackage` di-commit dengan benar
- Jika ada perubahan API endpoint: pastikan `APIEndpoint` protocol sudah sinkron dengan backend

## Catatan

- **Jangan force-push ke `main`** — safety hook akan memblokir
- Squash merge diutamakan agar history `main` bersih dan linear
