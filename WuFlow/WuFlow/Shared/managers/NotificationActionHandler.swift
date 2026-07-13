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

    func handleDone(activityId: String) {
        guard let activityId = UUID(uuidString: activityId) else {
            return
        }
        Task {
            do {
                guard let activity = try await repository.completeReminder(activityId: activityId) else {
                    print("Error: Could not find activity. This should never happen.")
                    return
                }
                NotificationManager.shared.sendSuccessNotification(activityName: activity.name)
            } catch {
                print(error)

            }
        }
    }
}
