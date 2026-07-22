//
//  AppContainer.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/12/26.
//
import Foundation
import SwiftData

final class AppContainer {
    
    let persistence: DataStore

    let repository: ActivityRepository

    let healthKitSyncService: HealthKitSyncService
    
    let locationService: LocationService

    let notificationActionHandler: NotificationActionHandler
    
    let locationAutomationEngine: LocationAutomationEngine
    
    let liveActivityManager: LiveActivityManager
    
    let sessionManager: SessionManager

    init() {
        self.persistence = DataStore.shared

        self.repository = ActivityRepository(modelContainer: persistence.container)

        self.healthKitSyncService = HealthKitSyncService(repository: repository)

        self.notificationActionHandler = NotificationActionHandler(repository: repository)
        
        self.sessionManager = SessionManager(repository: repository)
        
        self.liveActivityManager = LiveActivityManager()
        
        self.locationAutomationEngine = LocationAutomationEngine(repository: repository,
                                                                 sessionManager: sessionManager,
                                                                 liveActivityManager: liveActivityManager)

        self.locationService = LocationService(automationEngine: locationAutomationEngine)
    }
}
