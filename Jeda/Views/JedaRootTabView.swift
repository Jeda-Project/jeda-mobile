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

struct JedaRootTabView: View {
    @State private var selectedTab: JedaTab = .checkIn

    var body: some View {
        TabView(selection: $selectedTab) {
            EmotionClassificationDemoView()
                .tabItem {
                    Label(JedaTab.checkIn.title, systemImage: JedaTab.checkIn.systemImageName)
                }
                .tag(JedaTab.checkIn)

            JedaReflectionView()
            .tabItem {
                Label(JedaTab.reflection.title, systemImage: JedaTab.reflection.systemImageName)
            }
            .tag(JedaTab.reflection)

            HistoryRootView(weeks: HistorySampleData.weeks)
                .tabItem {
                    Label(JedaTab.history.title, systemImage: JedaTab.history.systemImageName)
                }
                .tag(JedaTab.history)
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
