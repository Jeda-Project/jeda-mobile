//
//  JedaStateViews.swift
//  Jeda
//
//  Created by Codex on 27/06/26.
//

import SwiftUI

enum JedaStateKind {
    case loading
    case empty
    case error

    var title: String {
        switch self {
        case .loading: "Membaca pola"
        case .empty: "Belum ada check-in"
        case .error: "Refleksi gagal dibuat"
        }
    }

    var message: String {
        switch self {
        case .loading: "Jeda sedang menyusun respons singkat dari entry terbaru."
        case .empty: "Mulai dari satu check-in singkat. Tidak perlu rapi."
        case .error: "Data tetap aman. Coba lagi saat koneksi stabil."
        }
    }

    var symbol: String {
        switch self {
        case .loading: "sparkles"
        case .empty: "square.and.pencil"
        case .error: "exclamationmark.triangle"
        }
    }

    var tint: Color {
        switch self {
        case .loading: JedaColor.dustyBlue
        case .empty: JedaColor.sage
        case .error: JedaColor.terracotta
        }
    }
}

struct JedaStateCard: View {
    let kind: JedaStateKind
    let message: String?
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        kind: JedaStateKind,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.kind = kind
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    private var displayMessage: String {
        message ?? kind.message
    }

    var body: some View {
        JedaGlassSurface(tint: kind.tint.opacity(0.12)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                Image(systemName: kind.symbol)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(kind.tint)
                    .frame(width: 44, height: 44)
                    .jedaGlassEffect(
                        tint: kind.tint.opacity(0.14),
                        in: Circle()
                    )

                VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                    Text(kind.title)
                        .font(JedaTypography.headline)
                        .foregroundStyle(JedaColor.textPrimary)

                    Text(displayMessage)
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let actionTitle, let action {
                    JedaButton(actionTitle, systemImage: "arrow.clockwise", kind: .secondary, action: action)
                }
            }
            .redacted(reason: kind == .loading ? .placeholder : [])
        }
    }
}
