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
    
    var sharedModelContainer: ModelContainer {
        DataStore.shared.container
    }
    
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
