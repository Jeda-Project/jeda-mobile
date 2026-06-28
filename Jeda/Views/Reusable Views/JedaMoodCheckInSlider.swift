/**
 * Scope: JedaMoodCheckInSlider.swift
 * Purpose: Compact mood slider that snaps to 5 discrete steps for the Check-in screen.
 */

import SwiftUI

struct JedaMoodCheckInSlider: View {
    @Binding var step: Int

    private let moods = JedaMood.allCases
    private let thumbSize: CGFloat = 44
    private let trackHeight: CGFloat = 44

    private var accent: Color {
        JedaMoodSliderCheckInColor.color(for: step)
    }

    var body: some View {
        JedaGlassSurface(tint: accent.opacity(0.15)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                Text("Mood Hari Ini")
                    .font(JedaTypography.headline)
                    .foregroundStyle(JedaColor.textPrimary)

                sliderTrack

                HStack {
                    ForEach(moods.indices, id: \.self) { i in
                        VStack(spacing: 2) {
                            Image(systemName: moods[i].symbol)
                                .font(.system(size: 12))
                            Text(moods[i].title)
                                .font(JedaTypography.caption)
                        }
                        .foregroundStyle(i == step ? accent : JedaColor.textSecondary)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .animation(.snappy(duration: 0.2), value: step)
    }

    private var sliderTrack: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let travel = max(width - thumbSize, 1)
            let stepWidth = travel / CGFloat(moods.count - 1)
            let x = CGFloat(step) * stepWidth

            ZStack(alignment: .leading) {
                trackBackground.frame(height: trackHeight)

                Circle()
                    .fill(.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay {
                        Image(systemName: moods[step].symbol)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(accent)
                    }
                    .jedaGlassEffect(
                        tint: accent.opacity(0.18),
                        isInteractive: true,
                        in: Circle()
                    )
                    .offset(x: x)
                    .animation(.snappy(duration: 0.2), value: step)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let rawStep = (gesture.location.x - thumbSize / 2) / stepWidth
                        let snapped = Int(rawStep.rounded())
                        let clamped = min(max(snapped, 0), moods.count - 1)
                        if clamped != step {
                            step = clamped
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
            )
            .accessibilityElement()
            .accessibilityLabel("Slider mood")
            .accessibilityValue(moods[step].title)
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: step = min(step + 1, moods.count - 1)
                case .decrement: step = max(step - 1, 0)
                default: break
                }
            }
        }
        .frame(height: trackHeight)
    }

    private var trackBackground: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.72, green: 0.40, blue: 0.31).opacity(0.5),
                        Color(red: 0.56, green: 0.64, blue: 0.68).opacity(0.5),
                        Color(red: 0.48, green: 0.55, blue: 0.50).opacity(0.5)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

private enum JedaMoodSliderCheckInColor {
    static func color(for step: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.72, green: 0.40, blue: 0.31),
            Color(red: 0.77, green: 0.60, blue: 0.49),
            Color(red: 0.56, green: 0.64, blue: 0.68),
            Color(red: 0.48, green: 0.55, blue: 0.50),
            Color(red: 0.40, green: 0.50, blue: 0.44),
        ]
        return colors[min(max(step, 0), colors.count - 1)]
    }
}

#Preview {
    @Previewable @State var step = 2
    ZStack {
        JedaScreenBackground()
        JedaMoodCheckInSlider(step: $step)
            .padding()
    }
}
