/**
 * Scope: JedaMoodSliderSupport.swift
 * Purpose: State and color interpolation types supporting JedaMoodSliderCard.
 */

import SwiftUI

enum JedaMoodSliderState: Equatable {
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

enum JedaMoodSliderColor {
    static let left = JedaColor.dustyBlue
    static let mid = JedaColor.sage
    static let right = JedaColor.clay

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

extension Color {
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
