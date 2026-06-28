//
//  JedaTheme.swift
//  Jeda
//
//  Created by Codex on 27/06/26.
//

import SwiftUI
import UIKit

enum JedaColor {
    static let sage = Color(red: 0.48, green: 0.55, blue: 0.50)
    static let dustyBlue = Color(red: 0.56, green: 0.64, blue: 0.68)
    static let clay = Color(red: 0.77, green: 0.60, blue: 0.49)
    static let terracotta = Color(red: 0.72, green: 0.40, blue: 0.31)

    static let background = Color(uiColor: .jedaBackground)
    static let elevatedBackground = Color(uiColor: .jedaElevatedBackground)
    static let textPrimary = Color(uiColor: .jedaTextPrimary)
    static let textSecondary = Color(uiColor: .jedaTextSecondary)
    static let separator = Color(uiColor: .jedaSeparator)
}

enum JedaRadius {
    static let chip: CGFloat = 16
    static let control: CGFloat = 16
    static let card: CGFloat = 16
}

enum JedaSpacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum JedaTypography {
    static let display = Font.system(.largeTitle, design: .rounded, weight: .semibold)
    static let title = Font.system(.title3, design: .rounded, weight: .semibold)
    static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body = Font.system(.body, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded, weight: .medium)
}

private extension UIColor {
    static let jedaBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.16, green: 0.18, blue: 0.17, alpha: 1.0)
        : UIColor(red: 0.96, green: 0.95, blue: 0.93, alpha: 1.0)
    }

    static let jedaElevatedBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.21, green: 0.23, blue: 0.22, alpha: 1.0)
        : UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0)
    }

    static let jedaTextPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.92, green: 0.91, blue: 0.88, alpha: 1.0)
        : UIColor(red: 0.23, green: 0.24, blue: 0.23, alpha: 1.0)
    }

    static let jedaTextSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.74, green: 0.75, blue: 0.72, alpha: 1.0)
        : UIColor(red: 0.39, green: 0.42, blue: 0.39, alpha: 1.0)
    }

    static let jedaSeparator = UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.47, green: 0.51, blue: 0.48, alpha: 0.34)
        : UIColor(red: 0.48, green: 0.55, blue: 0.50, alpha: 0.26)
    }
}

struct JedaScreenBackground: View {
    var body: some View {
        ZStack {
            JedaColor.background
            LinearGradient(
                colors: [
                    JedaColor.sage.opacity(0.20),
                    JedaColor.dustyBlue.opacity(0.10),
                    JedaColor.clay.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}
