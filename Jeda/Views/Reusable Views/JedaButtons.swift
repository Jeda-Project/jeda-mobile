//
//  JedaButtons.swift
//  Jeda
//
//  Created by Codex on 27/06/26.
//

import SwiftUI

enum JedaButtonKind {
    case primary
    case secondary
    case warning
}

struct JedaButton: View {
    let title: String
    let systemImage: String?
    let kind: JedaButtonKind
    let isLoading: Bool
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        kind: JedaButtonKind = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.kind = kind
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        styledButton
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .font(JedaTypography.headline)
            .allowsHitTesting(!isLoading)
    }

    @ViewBuilder
    private var styledButton: some View {
        switch kind {
        case .primary:
            button
                .jedaProminentButtonStyle(tint: JedaColor.sage)
        case .secondary:
            button
                .jedaGlassButtonStyle(tint: JedaColor.sage)
        case .warning:
            button
                .jedaProminentButtonStyle(tint: JedaColor.terracotta)
        }
    }

    private var button: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                if let systemImage {
                    Image(systemName: systemImage)
                }
            }
            .frame(maxWidth: .infinity)
            .opacity(isLoading ? 0.001 : 1)
            .background(alignment: .center) {
                if isLoading {
                    ProgressView()
                        .tint(kind == .secondary ? JedaColor.sage : Color.white)
                        .scaleEffect(0.7)
                }
            }
        }
    }
}

struct JedaIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(width: 44, height: 44)
        }
        .jedaIconGlassButtonStyle(tint: JedaColor.sage)
        .buttonBorderShape(.circle)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct JedaSolidBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(JedaColor.elevatedBackground)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(JedaColor.textPrimary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Kembali")
    }
}
