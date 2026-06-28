# /checkpoint [desc] — Safety Commit

Buat safety commit dengan timestamp untuk menyimpan progress saat ini.

## Penggunaan
```
/checkpoint sebelum refactor emotion service
/checkpoint UI draft mood picker
```

## Langkah

1. Stage semua perubahan: `git add -A`
2. Buat commit:
```bash
git commit -m "chore: checkpoint — <desc> [<ISO timestamp>]"
```

Contoh: `chore: checkpoint — sebelum refactor emotion service [2026-06-28T10:30:00]`

## Catatan

- Checkpoint commit tidak perlu lulus quality gate penuh
- Gunakan sebelum refactor besar atau eksperimen
- Bisa di-reset dengan `git reset HEAD~1` jika perlu
