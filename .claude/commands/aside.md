# /aside — Quick Side Task

Pause task saat ini, selesaikan pertanyaan atau fix kecil, lalu kembali.

## Langkah

1. **Jalankan `/checkpoint` dulu** — simpan safety commit + session log agar tidak ada yang hilang saat context dicompress
2. Selesaikan aside (tetap kecil — jika ini fitur baru, buka branch terpisah)
3. Jalankan quality gate jika ada kode yang diubah: `rtk xcodebuild build -project Jeda.xcodeproj -scheme Jeda -destination 'platform=iOS Simulator,name=iPhone 16' -quiet`
4. **Kembali** — nyatakan ulang task yang di-pause dari template di bawah dan lanjutkan

## Catatan

- Aside maksimal ~15 menit. Jika lebih besar, buat task/branch baru.
- Jangan gabungkan perubahan aside dengan fitur yang sedang dikerjakan dalam satu commit

## Template

```
## Aside: <apa>

### Task saat ini (di-pause)
- File: <path>
- Status: <di mana tadi>

### Aside task
<deskripsi>

### Kembali ke
<titik resume>
```
