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

    let notificationActionHandler: NotificationActionHandler

    init() {
        self.persistence = DataStore.shared

        self.repository = ActivityRepository(modelContainer: persistence.container)

        self.healthKitSyncService = HealthKitSyncService(repository: repository)

        self.notificationActionHandler = NotificationActionHandler(repository: repository)
    }
}
