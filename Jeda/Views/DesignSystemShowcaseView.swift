//
//  DesignSystemShowcaseView.swift
//  Jeda
//
//  Created by Codex on 27/06/26.
//

import SwiftUI

struct DesignSystemShowcaseView: View {
    @State private var selectedMood: JedaMood = .neutral
    @State private var moodSliderValue = 0.5
    @State private var journalText = "Aku capek lihat backlog yang tidak habis, tapi ada satu PR kecil yang akhirnya merged."

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: JedaSpacing.xl) {
                    header

                    JedaSection(
                        "Foundation",
                        subtitle: "Token warna dari PRD, radius konsisten, native SF Symbols, dan Liquid Glass iOS 26."
                    ) {
                        foundationGrid
                    }

                    JedaSection("Buttons") {
                        GlassEffectContainer(spacing: JedaSpacing.md) {
                            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                                JedaButton("Simpan check-in", systemImage: "checkmark", kind: .primary) {}
                                JedaButton("Cerita lebih dalam", systemImage: "arrow.up.message", kind: .secondary) {}
                                HStack {
                                    JedaIconButton(systemImage: "gearshape", accessibilityLabel: "Buka pengaturan") {}
                                    JedaIconButton(systemImage: "lock.shield", accessibilityLabel: "Buka privasi") {}
                                }
                            }
                        }
                    }

                    JedaSection(
                        "Daily Check-in",
                        subtitle: "Friction rendah: pilih mood, tulis satu entry, lalu simpan."
                    ) {
                        VStack(spacing: JedaSpacing.md) {
                            JedaMoodPicker(selectedMood: $selectedMood)
                            JedaMoodSliderCard(value: $moodSliderValue) {}
                            JedaJournalInput(
                                title: "Apa yang paling berat hari ini?",
                                prompt: "Jawab singkat juga cukup. Jeda mencari pola, bukan tulisan sempurna.",
                                text: $journalText
                            )
                        }
                    }

                    JedaSection("AI Reflection") {
                        JedaReflectionCard(
                            phrase: "backlog",
                            question: "Bagian mana dari backlog itu yang paling menguras kepala sekarang?"
                        ) {}
                    }

                    JedaSection("Weekly Pattern") {
                        JedaWeeklyPatternCard(
                            topics: ["backlog", "PR kecil", "energi sore", "takut lambat"],
                            moodTrend: "Lebih berat di awal minggu, mulai stabil setelah task kecil selesai.",
                            reliefNote: "Progress kecil terasa membantu saat target harian dibuat lebih sempit."
                        )
                    }

                    JedaSection(
                        "Grafik",
                        subtitle: "Swift Charts dibungkus komponen Jeda agar warna, radius, dan glass tetap konsisten."
                    ) {
                        VStack(spacing: JedaSpacing.md) {
                            JedaMoodTrendChartCard(
                                title: "Mood 7 hari",
                                subtitle: "Baca arah minggu, bukan nilai sempurna.",
                                points: [
                                    .init(day: "Sen", score: 2.0),
                                    .init(day: "Sel", score: 2.4),
                                    .init(day: "Rab", score: 3.0),
                                    .init(day: "Kam", score: 2.7),
                                    .init(day: "Jum", score: 3.5),
                                    .init(day: "Sab", score: 4.0),
                                    .init(day: "Min", score: 3.8)
                                ]
                            )

                            JedaTopicBarChartCard(
                                title: "Topik sering muncul",
                                subtitle: "Kata yang berulang dari entry minggu ini.",
                                items: [
                                    .init(topic: "backlog", count: 5),
                                    .init(topic: "fokus", count: 4),
                                    .init(topic: "energi", count: 3),
                                    .init(topic: "review", count: 2)
                                ]
                            )
                        }
                    }

                    JedaSection("Safety") {
                        JedaSafetyBanner {}
                    }

                    JedaSection("States") {
                        VStack(spacing: JedaSpacing.md) {
                            JedaStateCard(kind: .loading)
                            JedaStateCard(kind: .empty, actionTitle: "Mulai check-in") {}
                            JedaStateCard(kind: .error, actionTitle: "Coba lagi") {}
                        }
                    }
                }
                .padding(.horizontal, JedaSpacing.lg)
                .padding(.vertical, JedaSpacing.xl)
                .frame(maxWidth: 760, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background {
                JedaScreenBackground()
            }
            .navigationTitle("Design System")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.12), padding: JedaSpacing.xl) {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 46, weight: .semibold, design: .rounded))
                    .foregroundStyle(JedaColor.sage)

                VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                    Text("Jeda")
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .foregroundStyle(JedaColor.textPrimary)

                    Text("Design system MVP untuk ruang reflektif builder dan developer.")
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var foundationGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: JedaSpacing.md),
                GridItem(.flexible(), spacing: JedaSpacing.md)
            ],
            spacing: JedaSpacing.md
        ) {
            colorSwatch("Sage", color: JedaColor.sage)
            colorSwatch("Dusty Blue", color: JedaColor.dustyBlue)
            colorSwatch("Warm Clay", color: JedaColor.clay)
            colorSwatch("Terracotta", color: JedaColor.terracotta)
        }
    }

    private func colorSwatch(_ title: String, color: Color) -> some View {
        JedaGlassSurface(cornerRadius: JedaRadius.control, tint: color.opacity(0.12), padding: JedaSpacing.md) {
            VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color)
                    .frame(height: 54)

                Text(title)
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textPrimary)
            }
        }
    }
}

#Preview {
    DesignSystemShowcaseView()
}
