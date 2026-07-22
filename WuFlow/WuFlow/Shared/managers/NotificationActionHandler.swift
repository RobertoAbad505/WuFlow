//
//  NotificationActionHandler.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/8/26.
//

import Foundation
import SwiftData

final class NotificationActionHandler {

    private let repository: ActivityRepository

    init(repository: ActivityRepository) {
        self.repository = repository
    }

    func handleDone(
        activityId: String?,
        sessionId: String?
    ) async {
        guard
            let activityId,
            let sessionId,
            let activityUUID = UUID(uuidString: activityId),
            let sessionUUID = UUID(uuidString: sessionId) else {
            return
        }
        do {
            let activity = try await repository.completePlaceSession(
                activityID: activityUUID,
                sessionID: sessionUUID
            )
            NotificationManager.shared.sendSuccessNotification(
                activityName: activity.name
            )
        } catch {
            print(error)
        }
    }

    func handleLater(
        activityId: String?,
        sessionId: String?
    ) async {
        print("Later selected")
        // Future:
        // Reschedule notification
        // Snooze 15 minutes
    }

    func handleOpenNotification(
        activityId: String?,
        sessionId: String?
    ) async {
        print("Notification opened")
        // Future:
        // Deep link into Activity Detail
        // or Present Completion Sheet

    }
}
struct NotificationContext {

    let activityID: UUID?
    let sessionID: UUID?

    init(userInfo: [AnyHashable: Any]) {
        activityID = UUID(uuidString: userInfo["activityId"] as? String ?? "")
        sessionID = UUID(uuidString: userInfo["sessionId"] as? String ?? "")
    }
}
