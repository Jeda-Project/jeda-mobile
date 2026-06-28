//
//  JedaRootTabView.swift
//  Jeda
//
//  Created by Codex on 28/06/26.
//

import SwiftUI

enum JedaTab: String, CaseIterable, Identifiable {
    case checkIn
    case reflection
    case history

    var id: Self { self }

    var title: String {
        switch self {
        case .checkIn: "Check-in"
        case .reflection: "Refleksi"
        case .history: "History"
        }
    }

    var systemImageName: String {
        switch self {
        case .checkIn: "square.and.pencil"
        case .reflection: "sparkles"
        case .history: "clock.arrow.circlepath"
        }
    }
}

struct JedaTabBarHiddenPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func jedaHideTabBar(_ hidden: Bool = true) -> some View {
        preference(key: JedaTabBarHiddenPreferenceKey.self, value: hidden)
    }
}

struct JedaRootTabView: View {
    @State private var selectedTab: JedaTab = .checkIn
    @State private var isTabBarHidden: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .checkIn:
                    EmotionClassificationDemoView()
                case .reflection:
                    JedaReflectionView(onSaveCompleted: { selectedTab = .checkIn })
                case .history:
                    HistoryRootView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !isTabBarHidden {
                JedaFloatingTabBar(selection: $selectedTab)
                    .padding(.horizontal, JedaSpacing.lg)
                    .padding(.bottom, JedaSpacing.sm)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onPreferenceChange(JedaTabBarHiddenPreferenceKey.self) { hidden in
            withAnimation(.easeInOut(duration: 0.3)) {
                isTabBarHidden = hidden
            }
        }
        .tint(JedaColor.sage)
    }
}

private struct JedaPlaceholderTabView: View {
    let title: String
    let kind: JedaStateKind

    var body: some View {
        NavigationStack {
            ScrollView {
                JedaStateCard(kind: kind)
                    .padding(.horizontal, JedaSpacing.lg)
                    .padding(.vertical, JedaSpacing.xl)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
            }
            .background {
                JedaScreenBackground()
            }
            .navigationTitle(title)
        }
    }
}

#Preview {
    JedaRootTabView()
}
