# Session Log: OpenRouter Migration
Date: 2026-06-29
Branch: develop

## Objective
Migrate AI provider from OpenAI to OpenRouter to reduce costs. OpenRouter is API-compatible with OpenAI format — only base URL, headers, and model name needed to change.

## Model Selected
`nvidia/nemotron-3-ultra-550b-a55b:free` — ranked #1 intelligence on OpenRouter free tier, 1M context, fully free.

## Files Changed

| File | Change |
|------|--------|
| `Jeda/Services/AI/JedaAIConstants.swift` | Base URL → `openrouter.ai/api/v1/`, model → nemotron-3-ultra |
| `Jeda/Services/Networking/APIConfiguration.swift` | Replaced `openAI()` with `openRouter()` factory; added `HTTP-Referer: https://jeda.app` and `X-Title: Jeda` headers (required by OpenRouter) |
| `Jeda/Services/AI/AIAPIKeyProviding.swift` | Added `OPENROUTER_API_KEY` as first priority in lookup chain; kept `OPENAI_API_KEY` and `DICODING_AI_API_KEY` as fallback |
| `Jeda/Services/AI/AIService.swift` | `makeDefault()` now uses `.openRouter()` config; updated error message to reference `OPENROUTER_API_KEY` |

## OpenRouter Setup (Manual)
- API Key: created new key `Jeda iOS` with $1 credit limit, 180-day expiry
- Guardrail `Jeda iOS Policy` configured:
  - Model restricted: Only Allow → Nemotron 3 Ultra (free)
  - Prompt Injection: Block, User messages only
  - Sensitive Info Detection: Email + Phone → Redact
  - Free endpoints that may train on request data: **ON** (required — model gratis butuh ini)
- `Secrets.plist` (gitignored): entry `OPENROUTER_API_KEY` ditambahkan, `OPENAI_API_KEY` dihapus

## Issue Encountered
**Error 404:** "No endpoints available matching your guardrail restrictions and data policy"
- **Root cause:** Guardrail mematikan "Free endpoints that may train on request data", tapi Nemotron 3 Ultra (free) memerlukan endpoint ini
- **Fix:** Aktifkan kembali toggle tersebut di guardrail settings
- **Trade-off:** Model gratis memang retain/train on prompts — accepted risk untuk development phase

## Notes
- Loading time lambat (~10-30 detik) karena model 550B parameter — expected behavior
- Jika perlu lebih cepat, alternatif: `nvidia/llama-3.3-nemotron-super-49b-v1:free` (lebih kecil)
- `Secrets.plist` sudah di `.gitignore` — key aman dari repo
