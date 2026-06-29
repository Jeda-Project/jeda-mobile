/**
 * Scope: JedaGlassCompatibility.swift
 * Purpose: Compatibility shims for glass-effect APIs across different iOS versions.
 */

import SwiftUI

struct JedaGlassEffectContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder private let content: () -> Content

    init(spacing: CGFloat = 0, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing, content: content)
        } else if spacing > 0 {
            VStack(spacing: spacing, content: content)
        } else {
            content()
        }
    }
}

extension View {
    @ViewBuilder
    func jedaGlassEffect(
        tint: Color? = nil,
        isInteractive: Bool = false,
        in shape: some InsettableShape
    ) -> some View {
        if #available(iOS 26.0, *) {
            modifier(
                JedaNativeGlassEffectModifier(
                    tint: tint,
                    isInteractive: isInteractive,
                    shape: shape
                )
            )
        } else {
            background {
                JedaMaterialGlassBackground(
                    shape: shape,
                    tint: tint ?? JedaColor.sage.opacity(0.10),
                    isInteractive: isInteractive
                )
            }
        }
    }

    @ViewBuilder
    func jedaProminentButtonStyle(tint: Color = JedaColor.clay) -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glassProminent)
                .tint(tint)
        } else {
            buttonStyle(.borderedProminent)
                .tint(tint)
        }
    }

    @ViewBuilder
    func jedaGlassButtonStyle(tint: Color = JedaColor.sage) -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glass)
                .tint(tint)
        } else {
            buttonStyle(.bordered)
                .tint(tint)
        }
    }

    @ViewBuilder
    func jedaIconGlassButtonStyle(tint: Color = JedaColor.sage) -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glass)
                .tint(tint)
        } else {
            buttonStyle(.plain)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(tint.opacity(0.24), lineWidth: 0.75)
                }
        }
    }
}

@available(iOS 26.0, *)
private struct JedaNativeGlassEffectModifier<S: InsettableShape>: ViewModifier {
    let tint: Color?
    let isInteractive: Bool
    let shape: S

    func body(content: Content) -> some View {
        let base = Glass.regular.tint(tint)
        let effect = isInteractive ? base.interactive() : base
        content.glassEffect(effect, in: shape)
            .shadow(color: .clear, radius: 0)
    }
}

private struct JedaMaterialGlassBackground<S: InsettableShape>: View {
    let shape: S
    let tint: Color
    let isInteractive: Bool

    var body: some View {
        ZStack {
            shape.fill(.ultraThinMaterial)
            shape.fill(tint.opacity(isInteractive ? 0.20 : 0.14))
            shape.strokeBorder(Color.white.opacity(isInteractive ? 0.28 : 0.16), lineWidth: 0.5)
        }
    }
}
