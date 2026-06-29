/**
 * Scope: JedaMoodSliderCard.swift
 * Purpose: Card component with a slider for capturing mood intensity during kontemplasi.
 */

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
                    .foregroundStyle(JedaColor.textPrimary).multilineTextAlignment(.center)
                    .contentTransition(.numericText()).frame(maxWidth: .infinity)
                VStack(spacing: JedaSpacing.md) {
                    sliderTrack(accent: accent)
                    HStack { Text("Butuh jeda")
                        Spacer()
                        Text("Lebih lega")
                    }
                    .font(JedaTypography.caption).foregroundStyle(JedaColor.textSecondary).textCase(.uppercase)
                }
                Button { action() } label: {
                    Text("Lanjut").font(.system(.headline, design: .rounded, weight: .semibold))
                        .frame(maxWidth: .infinity).frame(height: 58)
                }
                .jedaProminentButtonStyle(tint: accent).buttonBorderShape(.capsule)
                .accessibilityLabel("Lanjut dengan mood \(state.title)")
            }
            .padding(.horizontal, JedaSpacing.lg).padding(.vertical, JedaSpacing.xl)
            .background {
                RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous)
                    .fill(backgroundGradient(for: accent))
            }
        }
        .animation(.snappy(duration: 0.25), value: state).animation(.snappy(duration: 0.18), value: value)
    }

    private func sliderTrack(accent: Color) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let travel = max(width - thumbSize, 1)
            let x = CGFloat(value) * travel

            ZStack(alignment: .leading) {
                Capsule().fill(JedaColor.elevatedBackground.opacity(0.38))
                    .jedaGlassEffect(tint: accent.opacity(0.10), in: Capsule())
                Capsule()
                    .fill(LinearGradient(
                        colors: [
                            JedaMoodSliderColor.left.opacity(0.34),
                            JedaMoodSliderColor.mid.opacity(0.30),
                            JedaMoodSliderColor.right.opacity(0.34)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: x + thumbSize / 2).opacity(0.72)
                Circle().fill(.white.opacity(0.92)).frame(width: thumbSize, height: thumbSize)
                    .shadow(color: accent.opacity(0.22), radius: 16, x: 0, y: 8)
                    .jedaGlassEffect(tint: .white.opacity(0.12), isInteractive: true, in: Circle()).offset(x: x)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { gesture in
                let next = (gesture.location.x - thumbSize / 2) / travel
                value = min(max(Double(next), 0), 1)
            })
            .accessibilityElement().accessibilityLabel("Slider mood")
            .accessibilityValue(JedaMoodSliderState.state(for: value).title)
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: value = min(value + 0.1, 1)
                case .decrement: value = max(value - 0.1, 0)
                default: break
                }
            }
            .accessibilityRepresentation { Slider(value: $value, in: 0 ... 1) { Text("Slider mood") } }
        }
        .frame(height: trackHeight)
    }

    private func backgroundGradient(for accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                accent.opacity(0.24), JedaColor.background.opacity(0.34), accent.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    @Previewable @State var value = 0.5
    ZStack { JedaScreenBackground()
        JedaMoodSliderCard(value: $value) {}.padding()
    }
}
