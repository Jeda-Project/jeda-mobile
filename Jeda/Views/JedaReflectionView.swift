/**
 * Scope: JedaReflectionView.swift
 * Purpose: Tab-level reflection history list, detail view, and deeper reflection input sheet.
 */

import SwiftUI

struct JedaReflectionView: View {
    @Environment(\.reflectionStore) private var store

    var body: some View {
        NavigationStack {
            Group {
                if store.entries.isEmpty {
                    emptyState
                } else {
                    entryList
                }
            }
            .background { JedaScreenBackground() }
            .navigationTitle("Refleksi")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                Text("Mari kita pelajari lebih dalam")
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)

                JedaStateCard(kind: .empty)
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.top, JedaSpacing.md)
            .padding(.bottom, JedaSpacing.xl)
        }
    }

    private var entryList: some View {
        List {
            ForEach(store.entries) { entry in
                NavigationLink(value: entry) {
                    ReflectionRowView(entry: entry)
                }
                .listRowBackground(JedaColor.elevatedBackground)
                .listRowSeparatorTint(JedaColor.separator)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .navigationDestination(for: ReflectionEntry.self) { entry in
            JedaReflectionDetailView(entry: entry)
        }
    }
}

private struct ReflectionRowView: View {
    let entry: ReflectionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.xs) {
            HStack {
                Text(entry.date, style: .date)
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)
                Spacer()
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(JedaColor.sage)
            }

            Text(entry.reflectionQuestion)
                .font(JedaTypography.headline)
                .foregroundStyle(JedaColor.textPrimary)
                .lineLimit(2)

            Text(entry.reflectionText)
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.textSecondary)
                .lineLimit(2)
        }
        .padding(.vertical, JedaSpacing.xs)
    }
}

struct JedaReflectionDetailView: View {
    let entry: ReflectionEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                excerptSection
                questionSection
                responseSection
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.top, JedaSpacing.md)
            .padding(.bottom, JedaSpacing.xl)
        }
        .background { JedaScreenBackground() }
        .navigationTitle(entry.date.formatted(date: .long, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var excerptSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.xs) {
            Label("Dari jurnal", systemImage: "book.closed")
                .font(JedaTypography.caption)
                .foregroundStyle(JedaColor.textSecondary)
                .accessibilityHidden(true)

            Text(entry.journalExcerpt)
                .font(.system(.body, design: .serif))
                .foregroundStyle(JedaColor.textPrimary)
                .italic()
                .lineSpacing(4)
        }
        .padding(JedaSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(JedaColor.elevatedBackground)
        .clipShape(RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous))
    }

    private var questionSection: some View {
        HStack(alignment: .top, spacing: JedaSpacing.md) {
            ZStack {
                Circle()
                    .fill(JedaColor.sage.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(JedaColor.sage)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                Text("Jeda · on-device")
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)

                Text(entry.reflectionQuestion)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(JedaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(JedaSpacing.lg)
        .background(JedaColor.elevatedBackground)
        .clipShape(RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous))
    }

    private var responseSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.xs) {
            Text("Refleksimu")
                .font(JedaTypography.caption)
                .foregroundStyle(JedaColor.textSecondary)

            Text(entry.reflectionText)
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(JedaSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(JedaColor.elevatedBackground)
        .clipShape(RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous))
    }
}

struct JedaDeeperReflectionView: View {
    let journalExcerpt: String
    let reflectionQuestion: String
    let onSave: (ReflectionEntry) -> Void

    @State private var reflectionText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                    excerptSection
                    aiQuestionSection
                    inputSection
                }
                .padding(.horizontal, JedaSpacing.lg)
                .padding(.top, JedaSpacing.md)
                .padding(.bottom, JedaSpacing.xl)
            }
            .background(JedaColor.background.ignoresSafeArea())
            .navigationTitle("Refleksi")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Tutup") { dismiss() }
                        .foregroundStyle(JedaColor.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simpan") { saveAndDismiss() }
                        .disabled(reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .foregroundStyle(JedaColor.sage)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var excerptSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.xs) {
            Label("Dari jurnal Anda kemarin:", systemImage: "book.closed")
                .font(JedaTypography.caption)
                .foregroundStyle(JedaColor.textSecondary)
                .accessibilityHidden(true)

            Text(journalExcerpt)
                .font(.system(.body, design: .serif))
                .foregroundStyle(JedaColor.textPrimary)
                .italic()
                .lineSpacing(4)
        }
        .padding(JedaSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(JedaColor.elevatedBackground)
        .clipShape(RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous))
    }

    private var aiQuestionSection: some View {
        HStack(alignment: .top, spacing: JedaSpacing.md) {
            ZStack {
                Circle()
                    .fill(JedaColor.sage.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(JedaColor.sage)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                Text("Jeda · on-device")
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)

                VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                    Text("Kamu menyebut \"\(highlightedKeyword)\" beberapa kali.")
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textPrimary)

                    Text(reflectionQuestion)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(JedaColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(JedaSpacing.lg)
        .background(JedaColor.elevatedBackground)
        .clipShape(RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous))
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.md) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $reflectionText)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 200)
                    .padding(JedaSpacing.md)
                    .background(JedaColor.elevatedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous)
                            .stroke(JedaColor.separator, lineWidth: 1)
                    }
                    .accessibilityLabel("Tulis refleksimu di sini")

                if reflectionText.isEmpty {
                    Text("Lanjut cerita...")
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textSecondary)
                        .padding(.top, JedaSpacing.md + 8)
                        .padding(.leading, JedaSpacing.md + 4)
                        .allowsHitTesting(false)
                }
            }

            HStack(spacing: JedaSpacing.md) {
                JedaButton("Simpan", systemImage: "checkmark", kind: .secondary) {
                    saveAndDismiss()
                }
                .disabled(reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                JedaButton("Lanjut", systemImage: "arrow.right", kind: .primary) {
                    saveAndDismiss()
                }
                .disabled(reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func saveAndDismiss() {
        let entry = ReflectionEntry(
            journalExcerpt: journalExcerpt,
            reflectionQuestion: reflectionQuestion,
            reflectionText: reflectionText
        )
        onSave(entry)
        dismiss()
    }

    private var highlightedKeyword: String {
        let stopWords = Set(["yang", "dan", "atau", "di", "ke", "dari", "ini", "itu", "saya", "aku", "kamu", "dengan", "untuk", "ada", "tidak", "bisa", "akan", "sudah", "jadi", "tapi", "juga", "kami", "mereka", "kita", "pada", "soal"])
        let words = journalExcerpt.split(separator: " ").map(String.init)
        return words.first(where: { $0.count > 4 && !stopWords.contains($0.lowercased()) }) ?? words.first ?? "sesuatu"
    }
}

#Preview("Tab – empty state") {
    JedaReflectionView()
}

#Preview("Tab – with entries") {
    let store = ReflectionStore()
    store.add(ReflectionEntry(
        journalExcerpt: "Sempat kepikiran soal review code yang tadi...",
        reflectionQuestion: "Apa yang paling challenging dari proses itu?",
        reflectionText: "Bagian paling sulit adalah ketika harus memberi feedback yang jujur tapi tetap membangun."
    ))
    return JedaReflectionView()
        .environment(\.reflectionStore, store)
}

#Preview("Deeper reflection sheet") {
    JedaDeeperReflectionView(
        journalExcerpt: "Sempat kepikiran soal review code yang tadi...",
        reflectionQuestion: "Apa yang paling challenging dari proses itu?",
        onSave: { _ in }
    )
}
