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
    @StateObject private var router = Router()
    
    let notificationDelegate = NotificationDelegate.shared
    
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
    
    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        NotificationManager.shared.registerNotificationCategories()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    router.handleDeepLink(url)
                }
                .environmentObject(router)
        }
        .modelContainer(sharedModelContainer)
    }
}
