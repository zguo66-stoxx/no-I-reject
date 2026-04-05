//
//  InsightsView.swift
//  NoIReject
//
//  Created by ZhilanGuo on 2026/4/4.
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \Moment.date) private var moments: [Moment]

    struct TagStat: Identifiable {
        var id: String { tag }
        let tag: String
        let totalScore: Int
        let count: Int
        var avgScore: Double { Double(totalScore) / Double(count) }
    }

    private var tagStats: [TagStat] {
        var dict: [String: (score: Int, count: Int)] = [:]
        for moment in moments {
            for tag in moment.tags {
                let existing = dict[tag] ?? (0, 0)
                dict[tag] = (existing.score + moment.score, existing.count + 1)
            }
        }
        return dict.map { TagStat(tag: $0.key, totalScore: $0.value.score, count: $0.value.count) }
            .sorted { $0.avgScore > $1.avgScore }
    }

    private var positiveTags: [TagStat] {
        tagStats.filter { $0.avgScore > 0 }
    }

    private var negativeTags: [TagStat] {
        tagStats.filter { $0.avgScore <= 0 }.sorted { $0.avgScore < $1.avgScore }
    }

    private var currentStreak: Int {
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var count = 0
        for _ in 0..<365 {
            let dayScore = moments
                .filter { cal.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.score }
            if dayScore > 0 {
                count += 1
            } else {
                break
            }
            guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return count
    }

    private var loggedDays: Int {
        Set(moments.map { Calendar.current.startOfDay(for: $0.date) }).count
    }

    private var overallEmoji: String {
        guard !moments.isEmpty else { return "✨" }
        let total = moments.reduce(0) { $0 + $1.score }
        return dailyEmoji(for: total / max(loggedDays, 1))
    }

    var body: some View {
        NavigationStack {
            List {
                // Summary cards
                Section {
                    HStack(spacing: 8) {
                        InsightCard(value: "\(moments.count)", label: "Moments", color: .blue)
                        InsightCard(value: "\(loggedDays)", label: "Days", color: .purple)
                        InsightCard(value: "\(currentStreak)🔥", label: "Streak", color: .orange)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                }

                if tagStats.isEmpty {
                    ContentUnavailableView(
                        "No insights yet",
                        systemImage: "lightbulb",
                        description: Text("Log moments with tags to discover what drives you.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    // Overall mood
                    Section("Your overall vibe") {
                        HStack {
                            Text(overallEmoji).font(.largeTitle)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Average daily score")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                let avg = moments.isEmpty ? 0 : moments.reduce(0) { $0 + $1.score } / max(loggedDays, 1)
                                Text(avg > 0 ? "+\(avg)" : "\(avg)")
                                    .font(.title2.bold())
                                    .foregroundStyle(avg > 0 ? .green : avg < 0 ? .orange : .primary)
                            }
                        }
                    }

                    if !positiveTags.isEmpty {
                        Section("What makes you happy 😊") {
                            ForEach(Array(positiveTags.prefix(5))) { stat in
                                TagStatRow(stat: stat)
                            }
                        }
                    }

                    if !negativeTags.isEmpty {
                        Section("What drains you 😔") {
                            ForEach(Array(negativeTags.prefix(5))) { stat in
                                TagStatRow(stat: stat)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Insights")
        }
    }
}

struct InsightCard: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TagStatRow: View {
    let stat: InsightsView.TagStat

    var body: some View {
        HStack {
            Text(stat.tag)
                .font(.headline)
            Spacer()
            Text("\(stat.count)×")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(stat.avgScore >= 0
                 ? String(format: "+%.0f avg", stat.avgScore)
                 : String(format: "%.0f avg", stat.avgScore))
                .font(.subheadline.bold())
                .foregroundStyle(stat.avgScore >= 0 ? .green : .orange)
                .frame(width: 72, alignment: .trailing)
        }
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: Moment.self, inMemory: true)
}
