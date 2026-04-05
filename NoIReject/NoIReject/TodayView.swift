//
//  TodayView.swift
//  NoIReject
//
//  Created by ZhilanGuo on 2026/4/4.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Moment.date, order: .reverse) private var allMoments: [Moment]
    @State private var showingAddSheet = false

    private var todayMoments: [Moment] {
        allMoments.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var todayScore: Int {
        todayMoments.reduce(0) { $0 + $1.score }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Score card
                VStack(spacing: 6) {
                    Text(todayMoments.isEmpty ? "✨" : dailyEmoji(for: todayScore))
                        .font(.system(size: 56))
                    Text(todayMoments.isEmpty
                         ? "No moments logged yet"
                         : "Score: \(todayScore > 0 ? "+" : "")\(todayScore)")
                        .font(.title3.bold())
                        .foregroundStyle(todayMoments.isEmpty ? .secondary : scoreColor(todayScore))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(.secondarySystemBackground))

                // Moments list
                List {
                    if todayMoments.isEmpty {
                        ContentUnavailableView(
                            "Log your first moment",
                            systemImage: "sparkles",
                            description: Text("Tap + to record something uncomfortable or exciting.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(todayMoments) { moment in
                            MomentRow(moment: moment)
                        }
                        .onDelete { offsets in
                            for i in offsets { modelContext.delete(todayMoments[i]) }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddMomentView()
            }
        }
    }
}

private func scoreColor(_ score: Int) -> Color {
    if score > 10 { return .green }
    if score < -10 { return .red }
    return .primary
}

struct MomentRow: View {
    let moment: Moment

    var body: some View {
        HStack(spacing: 12) {
            Text(moment.type == .excited ? "🚀" : "😤")
                .font(.title2)
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(moment.type == .excited ? "Excited" : "Uncomfortable")
                        .font(.headline)
                    Spacer()
                    Text(moment.score > 0 ? "+\(moment.score)" : "\(moment.score)")
                        .font(.headline.bold())
                        .foregroundStyle(moment.score > 0 ? .green : .orange)
                }
                if !moment.tags.isEmpty {
                    Text(moment.tags.joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !moment.note.isEmpty {
                    Text(moment.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TodayView()
        .modelContainer(for: Moment.self, inMemory: true)
}
