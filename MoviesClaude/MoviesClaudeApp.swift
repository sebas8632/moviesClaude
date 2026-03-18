//
//  MoviesClaudeApp.swift
//  MoviesClaude
//
//  Created by Juan Flores S on 16/03/26.
//

import SwiftUI
import SwiftData

@main
struct MoviesClaudeApp: App {
    let modelContainer: ModelContainer = {
        let schema = Schema([Movie.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: modelContainer.mainContext)
        }
        .modelContainer(modelContainer)
    }
}
