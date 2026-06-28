//
//  MainTabView.swift
//  Jeda
//

import SwiftUI

enum JedaMainTab: String, CaseIterable, Identifiable {
    case checkIn
    case history
    case insights
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .checkIn: "Check-in"
        case .history: "History"
        case .insights: "Insights"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .checkIn: "square.and.pencil"
        case .history: "clock.arrow.circlepath"
        case .insights: "chart.xyaxis.line"
        case .settings: "gearshape"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: JedaMainTab = .history

    var body: some View {
        TabView(selection: $selectedTab) {
            checkInTab
                .tabItem {
                    Label(JedaMainTab.checkIn.title, systemImage: JedaMainTab.checkIn.systemImage)
                }
                .tag(JedaMainTab.checkIn)

            HistoryRootView()
                .tabItem {
                    Label(JedaMainTab.history.title, systemImage: JedaMainTab.history.systemImage)
                }
                .tag(JedaMainTab.history)

            insightsTab
                .tabItem {
                    Label(JedaMainTab.insights.title, systemImage: JedaMainTab.insights.systemImage)
                }
                .tag(JedaMainTab.insights)

            settingsTab
                .tabItem {
                    Label(JedaMainTab.settings.title, systemImage: JedaMainTab.settings.systemImage)
                }
                .tag(JedaMainTab.settings)
        }
        .tint(JedaColor.sage)
    }

    private var checkInTab: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: JedaSpacing.xl) {
                    JedaSection(
                        "Daily Check-in",
                        subtitle: "Placeholder tab — gunakan design system showcase untuk komponen check-in."
                    ) {
                        JedaStateCard(kind: .empty, actionTitle: "Mulai check-in") {}
                    }
                }
                .padding(.horizontal, JedaSpacing.lg)
                .padding(.vertical, JedaSpacing.xl)
            }
            .background { JedaScreenBackground() }
            .navigationTitle("Check-in")
        }
    }

    private var insightsTab: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: JedaSpacing.xl) {
                    JedaSection("Insights", subtitle: "Pola jangka panjang akan muncul di sini.") {
                        JedaWeeklyPatternCard(
                            topics: ["backlog", "energi sore", "tidur"],
                            moodTrend: "Lebih berat di awal minggu, mulai stabil setelah task kecil selesai.",
                            reliefNote: "Progress kecil terasa membantu saat target harian dibuat lebih sempit."
                        )
                    }
                }
                .padding(.horizontal, JedaSpacing.lg)
                .padding(.vertical, JedaSpacing.xl)
            }
            .background { JedaScreenBackground() }
            .navigationTitle("Insights")
        }
    }

    private var settingsTab: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: JedaSpacing.xl) {
                    JedaSection("Settings", subtitle: "Pengaturan aplikasi.") {
                        JedaGlassSurface {
                            Label("Privasi & data", systemImage: "lock.shield")
                                .font(JedaTypography.body)
                                .foregroundStyle(JedaColor.textPrimary)
                        }
                    }
                }
                .padding(.horizontal, JedaSpacing.lg)
                .padding(.vertical, JedaSpacing.xl)
            }
            .background { JedaScreenBackground() }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    MainTabView()
}
