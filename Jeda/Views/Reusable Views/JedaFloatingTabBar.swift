/**
 * Scope: JedaFloatingTabBar.swift
 * Purpose: Custom floating pill-shaped tab bar matching Jeda's design system.
 */

import SwiftUI

struct JedaFloatingTabBar: View {
    @Binding var selection: JedaTab
    @Namespace private var selectionNamespace

    var body: some View {
        HStack(spacing: JedaSpacing.xs) {
            ForEach(JedaTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(JedaSpacing.xs)
        .background {
            Capsule()
                .fill(JedaColor.elevatedBackground)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        }
    }

    private func tabButton(for tab: JedaTab) -> some View {
        let isSelected = selection == tab

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.systemImageName)
                    .font(.system(size: 18, weight: .semibold))
                Text(tab.title)
                    .font(JedaTypography.caption)
            }
            .foregroundStyle(isSelected ? JedaColor.sage : JedaColor.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, JedaSpacing.sm)
            .background {
                if isSelected {
                    Capsule()
                        .fill(JedaColor.sage.opacity(0.16))
                        .matchedGeometryEffect(id: "selectedTab", in: selectionNamespace)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    @Previewable @State var selection: JedaTab = .checkIn

    ZStack {
        JedaScreenBackground()
        VStack {
            Spacer()
            JedaFloatingTabBar(selection: $selection)
                .padding(.horizontal, JedaSpacing.lg)
                .padding(.bottom, JedaSpacing.sm)
        }
    }
}
