//
//  NoIRejectApp.swift
//  NoIReject
//
//  Created by ZhilanGuo on 2026/4/4.
//

import SwiftUI
import SwiftData

@main
struct NoIRejectApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Moment.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Schema changed (e.g. during development) — wipe and recreate the store.
            let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [inMemoryConfig])
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
