/**
 * Scope: JedaReflectionView.swift
 * Purpose: Tab-level reflection list with pagination, pending reflection card, and navigation to detail screens.
 */

import SwiftUI

struct JedaReflectionView: View {
    @EnvironmentObject private var store: ReflectionStore
    @Environment(\.safetyService)
    private var safetyService

    var onSaveCompleted: () -> Void = {}

    @State private var showDeeperReflection = false
    @State private var showCrisisSheet = false
    @State private var crisisResources: [CrisisSupportResource] = [.sejiwa]

    var body: some View {
        NavigationStack {
            if store.entries.isEmpty && store.pendingReflection == nil {
                emptyState
            } else {
                mainContent
            }
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Refleksi")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(JedaColor.textPrimary)
                    .padding(.horizontal, JedaSpacing.lg)
                    .padding(.top, JedaSpacing.md)

                if let pending = store.pendingReflection {
                    JedaReflectionCard(
                        phrase: pending.highlightedPhrase,
                        question: pending.reflectionQuestion
                    ) {
                        showDeeperReflection = true
                    }
                    .padding(.horizontal, JedaSpacing.lg)
                    .padding(.top, JedaSpacing.lg)
                }

                LazyVStack(spacing: JedaSpacing.md) {
                    ForEach(Array(store.entries.enumerated()), id: \.element.id) { index, entry in
                        NavigationLink(value: entry) {
                            ReflectionRowView(entry: entry)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            let triggerIndex = max(0, store.entries.count - 3)
                            if index >= triggerIndex {
                                Task { await store.loadNextPage() }
                            }
                        }
                    }

                    if store.isLoadingMore {
                        ForEach(0 ..< 3, id: \.self) { _ in
                            ReflectionSkeletonRow()
                        }
                    }
                }
                .padding(.horizontal, JedaSpacing.lg)
                .padding(.top, JedaSpacing.lg)
                .padding(.bottom, JedaSpacing.xl + JedaSpacing.floatingTabBarClearance)
            }
        }
        .background { JedaScreenBackground() }
        .toolbar(.hidden, for: .navigationBar)
        .refreshable { await store.refreshFromBackend() }
        .navigationDestination(isPresented: $showDeeperReflection) {
            if let pending = store.pendingReflection {
                JedaDeeperReflectionView(
                    journalExcerpt: pending.journalExcerpt,
                    mood: pending.mood,
                    emotion: pending.emotion,
                    confidence: pending.confidence,
                    reflectionQuestion: pending.reflectionQuestion,
                    onSave: { entry in
                        store.add(entry)
                        store.clearPending()
                        onSaveCompleted()
                    }
                )
            }
        }
        .navigationDestination(for: ReflectionEntry.self) { entry in
            JedaReflectionDetailView(entry: entry)
        }
        .sheet(isPresented: $showCrisisSheet, onDismiss: { store.clearCrisisDetected() }, content: {
            JedaCrisisSupportSheet(resources: crisisResources)
        })
        .onChange(of: store.crisisDetected) { _, detected in
            guard detected else { return }
            showCrisisSheet = true
            Task {
                if let service = safetyService {
                    crisisResources = await service.resources()
                }
            }
        }
    }

    private var emptyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Refleksi")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(JedaColor.textPrimary)
                    .padding(.horizontal, JedaSpacing.lg)
                    .padding(.top, JedaSpacing.md)

                VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                    Text("Mari kita pelajari lebih dalam")
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textSecondary)
                    JedaStateCard(kind: .empty)
                }
                .padding(.horizontal, JedaSpacing.lg)
                .padding(.top, 8)
                .padding(.bottom, JedaSpacing.xl + JedaSpacing.floatingTabBarClearance)
            }
        }
        .background { JedaScreenBackground() }
        .toolbar(.hidden, for: .navigationBar)
        .refreshable { await store.refreshFromBackend() }
    }
}

#Preview("Tab – empty state") {
    JedaReflectionView()
        .environmentObject(ReflectionStore())
}
