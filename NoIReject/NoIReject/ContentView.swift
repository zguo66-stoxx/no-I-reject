//
//  ContentView.swift
//  NoIReject
//
//  Created by ZhilanGuo on 2026/4/4.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max.fill") }
            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
            YearView()
                .tabItem { Label("Year", systemImage: "chart.bar.fill") }
            InsightsView()
                .tabItem { Label("Insights", systemImage: "lightbulb.fill") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Moment.self, inMemory: true)
}
