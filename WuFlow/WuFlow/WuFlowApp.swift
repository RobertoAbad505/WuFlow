//
//  WuFlowApp.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 3/26/26.
//

import SwiftUI
import SwiftData

@main
struct WuFlowApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Activity.self,
            ProgressRecord.self 
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
