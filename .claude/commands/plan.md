# /plan — Feature Planning

Buat rencana implementasi terstruktur untuk fitur yang diminta.

## Langkah

1. **Baca konteks** sebelum mulai:
   - `AGENTS.md` — Golden Rules
   - `SSOT.md` — Arsitektur saat ini
   - `PRODUCT.md` — Konteks produk
   - File-file yang relevan dengan fitur

2. **Gunakan agent `planner`** untuk menghasilkan plan dengan struktur:
   - Scope (apa yang masuk dan tidak masuk)
   - Unknowns (pertanyaan yang perlu dijawab)
   - Task breakdown per layer (Models → Services → Views)
   - Risk assessment

3. **JANGAN mulai coding** sampai user mengkonfirmasi plan.

4. Tanyakan: "Plan ini sudah sesuai? Ada yang perlu diubah sebelum mulai implementasi?"

## Contoh Penggunaan
```
/plan Journal entry list dengan pagination
/plan Notifikasi pengingat journaling harian
/plan Integrasi backend API untuk sync data
```
