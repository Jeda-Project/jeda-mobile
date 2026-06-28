//
//  HistorySampleData.swift
//  Jeda
//

import Foundation

enum HistorySampleData {
    static let weeks: [WeekSummary] = [
        currentWeek,
        previousWeek(index: 1, weekNumber: 25, phrase: "Tenang tapi lelah", mood: .neutral, checkIns: 5),
        previousWeek(index: 2, weekNumber: 24, phrase: "Naik turun", mood: .low, checkIns: 4),
        previousWeek(index: 3, weekNumber: 23, phrase: "Lebih ringan", mood: .okay, checkIns: 6),
        previousWeek(index: 4, weekNumber: 22, phrase: "Fokus tapi tegang", mood: .neutral, checkIns: 5)
    ]

    static var currentWeek: WeekSummary {
        week26
    }

    static func week(withID id: UUID) -> WeekSummary? {
        weeks.first { $0.id == id }
    }

    static func entry(withID id: UUID, in week: WeekSummary) -> JournalEntry? {
        week.entries.first { $0.id == id }
    }

    private static let week26ID = weekID(for: 26)

    private static func weekID(for weekNumber: Int) -> UUID {
        // UUID segment terakhir butuh 12 karakter hex (8-4-4-4-12).
        UUID(uuidString: String(format: "A1000000-0000-0000-0000-%012d", weekNumber))!
    }

    private static var week26: WeekSummary {
        let start = date(year: 2025, month: 6, day: 22)
        let end = date(year: 2025, month: 6, day: 28)
        let entries = week26Entries(start: start)

        return WeekSummary(
            id: week26ID,
            weekNumber: 26,
            startDate: start,
            endDate: end,
            overallMood: .okay,
            moodLabel: "Lega",
            checkInCount: 6,
            totalDays: 7,
            summaryPhrase: "Stabil dengan momen lega di akhir minggu",
            topTopics: ["Deadline", "AI Project", "Tidur"],
            moodTrendPoints: [
                .init(day: "Sen", score: 2.2),
                .init(day: "Sel", score: 2.8),
                .init(day: "Rab", score: 3.1),
                .init(day: "Kam", score: 3.4),
                .init(day: "Jum", score: 3.8),
                .init(day: "Sab", score: 4.1),
                .init(day: "Min", score: 4.0)
            ],
            aiReflectionSummary: "Minggu ini dimulai dengan tekanan deadline, tapi kamu mulai menemukan ritme lagi setelah satu task kecil selesai. Pola \"takut lambat\" muncul di awal minggu, lalu berkurang saat progress terlihat.",
            aiReflectionLong: "\"Kamu menulis tentang deadline tiga kali sebelum akhirnya menulis tentang deploy yang selesai. Perpindahan itu menunjukkan bahwa lega datang bukan dari semua beban hilang, tapi dari satu langkah yang benar-benar selesai.\"",
            storyPages: [
                .init(
                    id: UUID(),
                    title: "The Week in a Glance",
                    symbol: "calendar",
                    body: "Minggu 26 dimulai berat karena backlog AI Project, lalu perlahan stabil setelah PR kecil merged dan tidur mulai teratur kembali."
                ),
                .init(
                    id: UUID(),
                    title: "Mood Journey",
                    symbol: "waveform.path.ecg",
                    body: "Mood naik dari Senin ke Jumat. Titik terendah di Selasa saat review code; titik tertinggi di Sabtu setelah deploy selesai."
                ),
                .init(
                    id: UUID(),
                    title: "Top Topics",
                    symbol: "text.bubble",
                    body: "Deadline, AI Project, dan tidur muncul paling sering. Kata \"takut\" dominan di awal minggu, digantikan \"lega\" di akhir."
                ),
                .init(
                    id: UUID(),
                    title: "Biggest Win",
                    symbol: "star.fill",
                    body: "Deploy akhirnya selesai di Sabtu malam. Kamu menulis dengan nada lebih ringan dan menyebut progress kecil terasa nyata."
                ),
                .init(
                    id: UUID(),
                    title: "Growth Highlight",
                    symbol: "leaf",
                    body: "Kamu mulai mempersempit target harian alih-alih menyerang seluruh backlog sekaligus — pola yang membantu mood stabil."
                )
            ],
            moodBreakdown: [
                .init(mood: .okay, count: 2),
                .init(mood: .neutral, count: 2),
                .init(mood: .low, count: 1),
                .init(mood: .heavy, count: 1)
            ],
            topicChartItems: [
                .init(topic: "Deadline", count: 5),
                .init(topic: "AI Project", count: 4),
                .init(topic: "Tidur", count: 3),
                .init(topic: "Review", count: 2)
            ],
            memorableMoments: Array(entries.prefix(3)),
            improvements: [
                "Lebih konsisten check-in sore",
                "Menulis soal tidur lebih jujur",
                "Memecah task besar jadi langkah kecil"
            ],
            quoteOfWeek: "\"Progress kecil terasa membantu saat target harian dibuat lebih sempit.\"",
            stats: .init(checkIns: 6, wordsWritten: 842, aiReflections: 4),
            wordCloud: ["takut", "deadline", "review", "deploy", "lega", "tidur", "fokus", "PR"],
            frequentEmotions: ["cloud.rain", "flame", "heart.fill", "sun.max.fill"],
            checkInRhythm: [true, true, true, true, true, true, false],
            entries: entries
        )
    }

    private static func week26Entries(start: Date) -> [JournalEntry] {
        [
            entry(
                id: UUID(uuidString: "B1000000-0000-0000-0000-000000000001")!,
                dayOffset: 0,
                start: start,
                mood: .low,
                title: "Backlog terasa tidak habis",
                snippet: "Aku capek lihat backlog yang tidak habis, tapi ada satu PR kecil yang akhirnya merged.",
                hour: 21, minute: 30,
                topics: ["Deadline", "AI Project"],
                question: "Bagian mana dari backlog itu yang paling menguras kepala sekarang?"
            ),
            entry(
                id: UUID(uuidString: "B1000000-0000-0000-0000-000000000002")!,
                dayOffset: 1,
                start: start,
                mood: .heavy,
                title: "Review code bikin cemas",
                snippet: "Takut komen review terlalu banyak dan bikin tim nunggu.",
                hour: 22, minute: 15,
                topics: ["Review"],
                question: "Apa yang paling kamu khawatirkan dari feedback review?"
            ),
            entry(
                id: UUID(uuidString: "B1000000-0000-0000-0000-000000000003")!,
                dayOffset: 2,
                start: start,
                mood: .neutral,
                title: "Mulai pecah task harian",
                snippet: "Hari ini cuma fokus satu slice kecil dari AI Project.",
                hour: 20, minute: 45,
                topics: ["AI Project", "Fokus"],
                question: "Slice kecil mana yang paling realistis untuk besok?"
            ),
            entry(
                id: UUID(uuidString: "B1000000-0000-0000-0000-000000000004")!,
                dayOffset: 3,
                start: start,
                mood: .neutral,
                title: "Tidur mulai teratur lagi",
                snippet: "Tidur jam 11 malam dan bangun lebih segar.",
                hour: 7, minute: 10,
                topics: ["Tidur"],
                question: "Ritual kecil apa yang membantu tidur lebih teratur?"
            ),
            entry(
                id: UUID(uuidString: "B1000000-0000-0000-0000-000000000005")!,
                dayOffset: 4,
                start: start,
                mood: .okay,
                title: "Sprint review lebih tenang",
                snippet: "Presentasi lancar, tekanan deadline masih ada tapi terkendali.",
                hour: 18, minute: 20,
                topics: ["Deadline"],
                question: "Apa yang membuat review kali ini terasa lebih tenang?"
            ),
            entry(
                id: UUID(uuidString: "B1000000-0000-0000-0000-000000000006")!,
                dayOffset: 5,
                start: start,
                mood: .light,
                title: "Deploy akhirnya selesai!",
                snippet: "Deploy akhirnya selesai! Rasanya lega banget setelah seminggu penuh tekanan.",
                hour: 22, minute: 15,
                topics: ["Deploy", "AI Project"],
                question: "Momen lega ini ingin kamu ingat sebagai apa?"
            )
        ]
    }

    private static func previousWeek(
        index: Int,
        weekNumber: Int,
        phrase: String,
        mood: JedaMood,
        checkIns: Int
    ) -> WeekSummary {
        let start = Calendar.current.date(byAdding: .weekOfYear, value: -index, to: week26.startDate)!
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start)!
        let id = weekID(for: weekNumber)

        return WeekSummary(
            id: id,
            weekNumber: weekNumber,
            startDate: start,
            endDate: end,
            overallMood: mood,
            moodLabel: mood.optimisticLabel,
            checkInCount: checkIns,
            totalDays: 7,
            summaryPhrase: phrase,
            topTopics: ["Kerja", "Istirahat"],
            moodTrendPoints: [
                .init(day: "Sen", score: 2.5),
                .init(day: "Min", score: 3.2)
            ],
            aiReflectionSummary: "Ringkasan minggu \(weekNumber): \(phrase).",
            aiReflectionLong: "Refleksi lengkap untuk minggu \(weekNumber) akan tersedia setelah lebih banyak entry terkumpul.",
            storyPages: [
                .init(
                    id: UUID(),
                    title: "The Week in a Glance",
                    symbol: "calendar",
                    body: phrase
                )
            ],
            moodBreakdown: [.init(mood: mood, count: checkIns)],
            topicChartItems: [.init(topic: "Kerja", count: 3)],
            memorableMoments: [],
            improvements: [],
            quoteOfWeek: nil,
            stats: .init(checkIns: checkIns, wordsWritten: 420, aiReflections: 2),
            wordCloud: ["kerja", "istirahat"],
            frequentEmotions: [mood.symbol],
            checkInRhythm: Array(repeating: false, count: 7).enumerated().map { $0.offset < checkIns },
            entries: []
        )
    }

    private static func entry(
        id: UUID,
        dayOffset: Int,
        start: Date,
        mood: JedaMood,
        title: String,
        snippet: String,
        hour: Int,
        minute: Int,
        topics: [String],
        question: String?
    ) -> JournalEntry {
        let day = Calendar.current.date(byAdding: .day, value: dayOffset, to: start)!
        var components = Calendar.current.dateComponents([.year, .month, .day], from: day)
        components.hour = hour
        components.minute = minute
        let timestamp = Calendar.current.date(from: components) ?? day

        return JournalEntry(
            id: id,
            date: day,
            mood: mood,
            title: title,
            snippet: snippet,
            body: snippet + " Ini versi lengkap entry untuk preview workflow History.",
            topics: topics,
            reflectionQuestion: question,
            timestamp: timestamp
        )
    }

    private static func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? .now
    }
}
