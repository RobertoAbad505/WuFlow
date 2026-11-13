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
    @Environment(\.scenePhase) private var scenePhase
    let notificationDelegate: NotificationDelegate
    
    let container: AppContainer
    
    init() {
        
        let router = Router()
        
        _router = StateObject(wrappedValue: router)
        container = AppContainer(router: router)
        
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
            container.healthKitSyncService.sync()
            restoreState()
        }
    }
    
    private func restoreState() {
        Task {
            if let session = await container.sessionManager.activePlaceSession() {
                await container.liveActivityManager.ensureLiveActivity(
                    for: session
                )
            }
        }
    }
}
