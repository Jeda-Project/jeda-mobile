//
//  JedaMoodPicker.swift
//  Jeda
//
//  Created by Codex on 27/06/26.
//

import SwiftUI

enum JedaMood: Int, CaseIterable, Identifiable {
    case heavy = 1
    case low
    case neutral
    case okay
    case light

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .heavy: "Berat"
        case .low: "Turun"
        case .neutral: "Netral"
        case .okay: "Oke"
        case .light: "Ringan"
        }
    }

    var symbol: String {
        switch self {
        case .heavy: "cloud.rain"
        case .low: "cloud"
        case .neutral: "circle"
        case .okay: "sun.min"
        case .light: "sun.max"
        }
    }

    var tint: Color {
        switch self {
        case .heavy: JedaColor.dustyBlue
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
