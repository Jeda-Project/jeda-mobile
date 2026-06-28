# Anti-Pattern: `.task {}` vs `.onAppear {}`

## Masalah

Menggunakan `.onAppear` untuk async work menyebabkan Task yang tidak bisa di-cancel ketika View menghilang, berpotensi menyebabkan memory leak dan update pada View yang sudah di-dismiss.

## ❌ Anti-Pattern

```swift
struct JedaJournalListView: View {
    @State private var entries: [JournalEntry] = []

    var body: some View {
        List(entries) { entry in
            JournalEntryRow(entry: entry)
        }
        .onAppear {
            // ❌ Task ini tidak di-cancel saat View hilang
            Task {
                entries = try await journalService.fetchEntries()
            }
        }
    }
}
```

**Masalah:**
- Task terus berjalan meski View sudah di-dismiss (misalnya, user tap Back sebelum fetch selesai)
- Jika fetch selesai setelah View di-dismiss, update state terjadi pada View yang sudah tidak ada
- Tidak memanfaatkan lifecycle binding SwiftUI

## ✅ Pattern yang Benar

```swift
struct JedaJournalListView: View {
    @State private var entries: [JournalEntry] = []

    var body: some View {
        List(entries) { entry in
            JournalEntryRow(entry: entry)
        }
        .task {
            // ✅ Task otomatis di-cancel saat View hilang
            do {
                entries = try await journalService.fetchEntries()
            } catch {
                // Handle error
            }
        }
    }
}
```

## Kapan Gunakan `.onAppear`

`.onAppear` cocok untuk:
- Sync operations (set analytics flag, update @State local)
- Side effects yang tidak butuh cancellation

```swift
.onAppear {
    // ✅ Sync, tidak butuh cancellation
    Analytics.logEvent("journal_list_viewed", parameters: nil)
    hasSeenList = true
}
```

## Kapan Gunakan `.task`

`.task` untuk semua async work:
- Networking / API calls
- Core ML inference
- Disk I/O
- Operasi async apapun yang harus di-cancel saat View hilang

## Catatan

`.task` dengan `id:` parameter akan re-run task setiap kali nilai `id` berubah — berguna untuk refresh:

```swift
.task(id: refreshTrigger) {
    entries = try await journalService.fetchEntries()
}
```
