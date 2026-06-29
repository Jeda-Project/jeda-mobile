/**
 * Scope: JedaMoodPicker.swift
 * Purpose: Reusable mood selection component that lets users pick from available emotion options.
 */

import SwiftUI

enum JedaMood: Int, CaseIterable, Identifiable, Codable {
    case heavy = 1
    case low
    case neutral
    case okay
    case light

    var id: Int {
        rawValue
    }

    var title: String {
        switch self {
        case .heavy: "Berat"
        case .low: "Lelah"
        case .neutral: "Netral"
        case .okay: "Lega"
        case .light: "Tenteram"
        }
    }

    var symbol: String {
        switch self {
        case .heavy: "cloud.rain"
        case .low: "flame"
        case .neutral: "heart.fill"
        case .okay: "sun.max.fill"
        case .light: "sparkles"
        }
    }

    var checkInStepIndex: Int {
        rawValue - 1
    }

    static func mood(forCheckInStep step: Int) -> JedaMood {
        JedaMood(rawValue: step + 1) ?? .neutral
    }

    var tint: Color {
        switch self {
        case .heavy: JedaColor.terracotta
        case .low: JedaColor.sage.opacity(0.78)
        case .neutral: JedaColor.sage
        case .okay: JedaColor.clay.opacity(0.82)
        case .light: JedaColor.clay
        }
    }
}

struct JedaMoodPicker: View {
    @Binding var selectedMood: JedaMood

    var body: some View {
        JedaGlassEffectContainer(spacing: JedaSpacing.sm) {
            HStack(spacing: JedaSpacing.sm) {
                ForEach(JedaMood.allCases) { mood in
                    Button {
                        selectedMood = mood
                    } label: {
                        VStack(spacing: JedaSpacing.xs) {
                            Image(systemName: mood.symbol)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .symbolRenderingMode(.hierarchical)
                                .accessibilityHidden(true)

                            Text(mood.title)
                                .font(JedaTypography.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 76)
                        .foregroundStyle(selectedMood == mood ? JedaColor.textPrimary : JedaColor.textSecondary)
                        .background {
                            RoundedRectangle(cornerRadius: JedaRadius.control, style: .continuous)
                                .fill(selectedMood == mood ? mood.tint.opacity(0.18) : Color.clear)
                        }
                        .jedaGlassEffect(
                            tint: selectedMood == mood ? mood.tint.opacity(0.22) : JedaColor.sage.opacity(0.06),
                            isInteractive: true,
                            in: RoundedRectangle(cornerRadius: JedaRadius.control, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Mood \(mood.title)")
                    .accessibilityAddTraits(selectedMood == mood ? .isSelected : [])
                }
            }
        }
    }
}
