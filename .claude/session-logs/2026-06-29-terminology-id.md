# Session Log — 2026-06-29 — terminology-id

## Scope
Penggantian terminologi UI dari bahasa Inggris ke bahasa Indonesia untuk user-facing strings.

## Keputusan

### "Check-in" → "Kontemplasi"
- Semua string yang tampil ke user diganti
- Property/function/type names dalam kode (`checkIn`, `checkInCount`, dll) TIDAK disentuh
- Berlaku untuk: label, empty state, error messages, AI reflection strings, section titles, onboarding subtitle

### "History" → "Histori"
- Hanya tab label dan 1 preview text yang diganti
- Type names (`HistoryModels`, `HistoryWeekCatalog`, dll) TIDAK disentuh

## Files Modified

| File | Perubahan |
|------|-----------|
| `Jeda/Views/JedaRootTabView.swift` | Tab label: `"Check-in"` → `"Kontemplasi"`, `"History"` → `"Histori"` |
| `Jeda/Views/History/WeeklySummaryView.swift` | Progress bar label `"Check-ins"` → `"Kontemplasi"` |
| `Jeda/Views/History/WeeklySummaryDetailSections.swift` | Section title `"Ritme Check-in"` → `"Ritme Kontemplasi"` |
| `Jeda/Views/Reusable Views/JedaStateViews.swift` | 2 empty state strings |
| `Jeda/Views/Reusable Views/JedaHistoryComponents.swift` | 2 progress bar labels + 1 stat cell title |
| `Jeda/Views/JedaOnboardingView.swift` | Onboarding page subtitle + id |
| `Jeda/Models/History/HistoryWeekCatalog.swift` | 3 AI reflection strings |
| `Jeda/Models/History/HistorySampleData.swift` | 1 improvement string + 1 preview text |
| `Jeda/Services/AI/MockAICompletingService.swift` | 4 mock AI strings |
| `Jeda/Services/History/WeeklySummaryLoader.swift` | 2 error messages |
| `Jeda/Services/Persistence/ReflectionPersisting.swift` | 2 error messages + docblock |
| `Jeda/Views/EmotionClassificationDemoView.swift` | Docblock |
| `Jeda/Views/Reflection/JedaDeeperReflectionView.swift` | Docblock |
| `Jeda/Views/Reusable Views/JedaMoodSliderCard.swift` | Docblock |
| `Jeda/Models/ReflectionStore.swift` | Docblock |
