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
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        kind: JedaButtonKind = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.kind = kind
        self.action = action
    }

    var body: some View {
        Group {
            switch kind {
            case .primary:
                button
                    .buttonStyle(.glassProminent)
                    .tint(JedaColor.clay)
            case .secondary:
                button
                    .buttonStyle(.glass)
                    .tint(JedaColor.sage)
            case .warning:
                button
                    .buttonStyle(.glassProminent)
                    .tint(JedaColor.terracotta)
            }
        }
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .font(JedaTypography.headline)
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
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .tint(JedaColor.sage)
        .accessibilityLabel(accessibilityLabel)
    }
}
