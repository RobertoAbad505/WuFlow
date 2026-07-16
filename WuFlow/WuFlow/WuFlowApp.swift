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
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var router = Router()
    let notificationDelegate: NotificationDelegate
    
    let container = AppContainer()
    
    init() {
        notificationDelegate = NotificationDelegate(actionHandler: container.notificationActionHandler)
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
                .environment(container.healthKitSyncService)
                .environment(\.repository, container.repository)
                .environment(container.locationService)
        }
        .modelContainer(container.persistence.container)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else {
                return
            }
//            container.healthKitSyncService.sync()
        }
    }
}
