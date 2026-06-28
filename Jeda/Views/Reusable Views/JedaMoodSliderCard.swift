//
//  JedaMoodSliderCard.swift
//  Jeda
//
//  Created by Codex on 28/06/26.
//

import SwiftUI

struct JedaMoodSliderCard: View {
    @Binding var value: Double
    let action: () -> Void

    private let thumbSize: CGFloat = 58
    private let trackHeight: CGFloat = 58

    var body: some View {
        let state = JedaMoodSliderState.state(for: value)
        let accent = JedaMoodSliderColor.color(for: value)

        JedaGlassSurface(
            tint: accent.opacity(0.18),
            isInteractive: true,
            padding: 0
        ) {
            VStack(spacing: JedaSpacing.xl) {
                Text(state.title)
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(JedaColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .contentTransition(.numericText())
                    .frame(maxWidth: .infinity)

                VStack(spacing: JedaSpacing.md) {
                    sliderTrack(accent: accent)

                    HStack {
                        Text("Butuh jeda")
                        Spacer()
                        Text("Lebih lega")
                    }
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)
                    .textCase(.uppercase)
                }

                Button {
                    action()
                } label: {
                    Text("Lanjut")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                }
                .jedaProminentButtonStyle(tint: accent)
                .buttonBorderShape(.capsule)
                .accessibilityLabel("Lanjut dengan mood \(state.title)")
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.vertical, JedaSpacing.xl)
            .background {
                RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous)
                    .fill(backgroundGradient(for: accent))
            }
        }
        .animation(.snappy(duration: 0.25), value: state)
        .animation(.snappy(duration: 0.18), value: value)
    }

    private func sliderTrack(accent: Color) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let travel = max(width - thumbSize, 1)
            let x = CGFloat(value) * travel

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(JedaColor.elevatedBackground.opacity(0.38))
                    .jedaGlassEffect(
                        tint: accent.opacity(0.10),
                        in: Capsule()
                    )

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                JedaMoodSliderColor.left.opacity(0.34),
                                JedaMoodSliderColor.mid.opacity(0.30),
                                JedaMoodSliderColor.right.opacity(0.34)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: x + thumbSize / 2)
                    .opacity(0.72)

                Circle()
                    .fill(.white.opacity(0.92))
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: accent.opacity(0.22), radius: 16, x: 0, y: 8)
                    .jedaGlassEffect(
                        tint: .white.opacity(0.12),
                        isInteractive: true,
                        in: Circle()
                    )
                    .offset(x: x)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let next = (gesture.location.x - thumbSize / 2) / travel
                        value = min(max(Double(next), 0), 1)
                    }
            )
            .accessibilityElement()
            .accessibilityLabel("Slider mood")
            .accessibilityValue(JedaMoodSliderState.state(for: value).title)
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    value = min(value + 0.1, 1)
                case .decrement:
                    value = max(value - 0.1, 0)
                default:
                    break
                }
            }
            .accessibilityRepresentation {
                Slider(value: $value, in: 0...1) {
                    Text("Slider mood")
                }
            }
        }
        .frame(height: trackHeight)
    }

    private func backgroundGradient(for accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                accent.opacity(0.24),
                JedaColor.background.opacity(0.34),
                accent.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private enum JedaMoodSliderState: Equatable {
    case veryHeavy
    case heavy
    case neutral
    case easing
    case light

    var title: String {
        switch self {
        case .veryHeavy: "Sangat berat"
        case .heavy: "Agak berat"
        case .neutral: "Netral"
        case .easing: "Mulai lega"
        case .light: "Ringan"
        }
    }

    static func state(for value: Double) -> JedaMoodSliderState {
        switch value {
        case ..<0.18: .veryHeavy
        case ..<0.38: .heavy
        case ..<0.62: .neutral
        case ..<0.84: .easing
        default: .light
        }
    }
}

private enum JedaMoodSliderColor {
    static let left = Color(red: 0.56, green: 0.64, blue: 0.68)
    static let mid = Color(red: 0.48, green: 0.55, blue: 0.50)
    static let right = Color(red: 0.77, green: 0.60, blue: 0.49)

    static func color(for value: Double) -> Color {
        let clamped = min(max(value, 0), 1)

        if clamped < 0.5 {
            return interpolate(from: left, to: mid, progress: clamped / 0.5)
        } else {
            return interpolate(from: mid, to: right, progress: (clamped - 0.5) / 0.5)
        }
    }

    private static func interpolate(from start: Color, to end: Color, progress: Double) -> Color {
        let startRGB = start.components
        let endRGB = end.components
        let eased = progress * progress * (3 - 2 * progress)

        return Color(
            red: startRGB.red + (endRGB.red - startRGB.red) * eased,
            green: startRGB.green + (endRGB.green - startRGB.green) * eased,
            blue: startRGB.blue + (endRGB.blue - startRGB.blue) * eased
        )
    }
}

private extension Color {
    var components: (red: Double, green: Double, blue: Double) {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (Double(red), Double(green), Double(blue))
        #else
        return (0, 0, 0)
        #endif
    }
}

#Preview {
    @Previewable @State var value = 0.5

    ZStack {
        JedaScreenBackground()
        JedaMoodSliderCard(value: $value) {}
            .padding()
    }
}
