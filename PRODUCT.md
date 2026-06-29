# PRODUCT.md — Jeda iOS

## What is Jeda?

**Jeda** is a mental health journaling app for iOS that helps users understand their emotional patterns through writing. The name "Jeda" (Indonesian for "pause/break") reflects the product philosophy: giving a brief space for self-reflection amid the busyness of daily life.

Core feature: users write a daily journal entry, and on-device AI automatically classifies the emotion in that text using a fine-tuned IndoBERT model.

## Target Users

- Young Indonesian adults (18–35 years old)
- Interested in self-improvement and mental health awareness
- Comfortable with technology but value privacy (on-device AI = no data sent to a server)
- Primary language: Indonesian

## Brand Personality

- **Calm** — does not induce panic, not overwhelming
- **Warm** — supportive, not clinical or cold
- **Honest** — does not overpromise on "curing" mental health issues
- **Smart** — built on real AI (not a gimmick), explained simply

## Design Philosophy

**Calm/Muted Palette** — not dark neon, not bright pastel. A calming tone:
- Sage green (`#7A8B7F`) — balance, nature
- Dusty blue (`#8FA3AD`) — calm, trust
- Warm clay (`#C49A7C`) — warmth, groundedness
- Terracotta (`#B8654F`) — warm energy, grounded

**UI Principles:**
- Generous whitespace — never cluttered
- Easy-to-read typography (full Dynamic Type support)
- Minimal, purposeful animation — no decorative animation
- Native iOS feel — follows HIG rather than custom UI that fights the platform

**Anti-references:**
- Not an overly gamified mood tracker (excessive streaks, badges)
- Not a "techy" design with neon/dark cyber colors
- Not clinical like a medical app

## Existing Features

1. **Emotion Classification Demo** — Text input, emotion classification output (sadness, anger, love, fear, happy) with a confidence score
2. **Design System Showcase** — Reference view for all Jeda components
3. **Reusable Component Library:**
   - JedaButtons, JedaCharts, JedaGlassSurface
   - JedaJournalInput, JedaMoodPicker, JedaMoodSliderCard
   - JedaReflectionCard, JedaSafetyBanner, JedaStateViews, JedaWeeklyPatternCard

## Planned Features

- Full journal entry flow (compose → save → list)
- Emotion history & trend chart
- Weekly/monthly emotion report
- Reflection prompts based on the detected emotion
- Safety net for crisis content (JedaSafetyBanner already exists)
- Backend API integration (infrastructure already available in Services/Networking/)

## Important Constraints

- **Privacy first:** Emotion classification happens entirely on-device (Core ML). No journal text is sent to a server.
- **Indonesian language:** Error messages, UI copy, and accessibility labels are in Indonesian.
- **iOS only:** No Android or cross-platform plans in the near term.
