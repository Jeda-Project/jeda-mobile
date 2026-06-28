# PRODUCT.md — Jeda iOS

## Apa itu Jeda?

**Jeda** adalah aplikasi journaling kesehatan mental untuk iOS yang membantu pengguna memahami pola emosi mereka melalui tulisan. Nama "Jeda" (Bahasa Indonesia: "pause/break") mencerminkan filosofi produk: memberi ruang sejenak untuk refleksi diri di tengah kesibukan sehari-hari.

Fitur utama: pengguna menulis jurnal harian, lalu AI on-device secara otomatis mengklasifikasikan emosi dari tulisan tersebut menggunakan model IndoBERT yang telah di-fine-tune.

## Target Pengguna

- Dewasa muda Indonesia (18–35 tahun)
- Tertarik dengan self-improvement dan mental health awareness
- Nyaman dengan teknologi namun menghargai privacy (on-device AI = tidak ada data dikirim ke server)
- Bahasa utama: Indonesia

## Brand Personality

- **Tenang** — tidak membuat panik, tidak overwhelming
- **Hangat** — supportif, bukan klinis atau dingin
- **Jujur** — tidak overpromise soal "menyembuhkan" masalah mental health
- **Cerdas** — berbasis AI nyata (bukan gimmick), dijelaskan dengan sederhana

## Design Philosophy

**Calm/Muted Palette** — bukan dark neon, bukan pastel cerah. Tone yang menenangkan:
- Sage green (`#7A8B7F`) — keseimbangan, alam
- Dusty blue (`#8FA3AD`) — ketenangan, kepercayaan
- Warm clay (`#C49A7C`) — kehangatan, tanah
- Terracotta (`#B8654F`) — energi hangat, grounded

**Prinsip UI:**
- Whitespace yang lega — tidak cluttered
- Typography yang mudah dibaca (Dynamic Type support penuh)
- Animasi minimal dan purposeful — tidak ada animasi dekoratif
- Native iOS feel — mengikuti HIG, bukan custom UI yang fighting dengan platform

**Anti-references:**
- Bukan aplikasi mood tracker yang terlalu gamified (streak, badges berlebihan)
- Bukan desain "techy" dengan warna neon/dark cyber
- Bukan klinis seperti aplikasi medical

## Fitur yang Ada

1. **Emotion Classification Demo** — Input teks, output klasifikasi emosi (sadness, anger, love, fear, happy) dengan confidence score
2. **Design System Showcase** — Reference view untuk semua komponen Jeda
3. **Reusable Component Library:**
   - JedaButtons, JedaCharts, JedaGlassSurface
   - JedaJournalInput, JedaMoodPicker, JedaMoodSliderCard
   - JedaReflectionCard, JedaSafetyBanner, JedaStateViews, JedaWeeklyPatternCard

## Fitur yang Direncanakan

- Journal entry full flow (compose → save → list)
- Emotion history & trend chart
- Weekly/monthly emotion report
- Reflection prompts berbasis emosi terdeteksi
- Safety net untuk konten krisis (sudah ada JedaSafetyBanner)
- Backend API integration (infrastructure sudah tersedia di Services/Networking/)

## Constraint Penting

- **Privacy first:** Klasifikasi emosi terjadi sepenuhnya on-device (Core ML). Tidak ada teks jurnal yang dikirim ke server.
- **Bahasa Indonesia:** Error messages, UI copy, dan accessibility labels dalam Bahasa Indonesia.
- **iOS only:** Tidak ada rencana Android atau cross-platform dalam waktu dekat.
