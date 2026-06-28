# Security Guidelines

## Mandatory Security Checks

Sebelum SETIAP commit:

- [ ] Tidak ada hardcoded API key, token, atau password di Swift files
- [ ] Data sensitif disimpan di Keychain, bukan UserDefaults
- [ ] Tidak ada `http://` URL di production config — harus `https://`
- [ ] Teks jurnal user TIDAK dikirim ke server (on-device ML only)
- [ ] `GoogleService-Info.plist` tidak mengandung production key di repo publik
- [ ] Error messages tidak mengekspos internal detail ke user

## Secret Management

- JANGAN hardcode secrets di source code
- GUNAKAN environment variables atau Xcode configuration files (`.xcconfig`)
- Firebase config: `GoogleService-Info.plist` harus di `.gitignore` untuk production keys
- Token API: simpan di Keychain, bukan di `UserDefaults` atau `Info.plist`

## Data Privacy (Kritis untuk Jeda)

Jeda adalah aplikasi kesehatan mental — data user sangat sensitif:

- **On-device only:** Teks jurnal dan hasil klasifikasi emosi TIDAK boleh dikirim ke server tanpa consent eksplisit user
- **Minimal data collection:** Hanya kumpulkan analytics yang benar-benar dibutuhkan
- **No PII in analytics:** Jangan kirim nama, email, atau konten jurnal sebagai Firebase Analytics parameter
- **Keychain untuk auth token:** Jika ada backend auth di masa depan, token harus di Keychain

## Network Security

```swift
// ✅ Selalu HTTPS
let baseURL = URL(string: "https://api.jeda.app")!

// ❌ HTTP tidak diizinkan
let baseURL = URL(string: "http://api.jeda.app")!
```

App Transport Security (ATS) harus aktif — jangan tambahkan `NSAllowsArbitraryLoads` di `Info.plist` tanpa alasan kuat yang terdokumentasi.

## Security Response Protocol

Jika ditemukan security issue:

1. **STOP** — jangan lanjutkan task lain
2. Fix issue KRITIS sebelum commit apapun
3. Rotate secrets yang mungkin terekspos
4. Review file terkait untuk issue serupa
5. Dokumentasikan fix di commit message
