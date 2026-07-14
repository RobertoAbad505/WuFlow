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
        Task {
            guard let activityId = UUID(uuidString: activityId) else {
                print("Handle done: Invalid UUID")
                return
            }
            do {
                guard let activity = try await repository.completeReminder(activityId: activityId) else {
                    print("Handle done: Duplication prevention ON - Activity already completed")
                    return
                }
                NotificationManager.shared.sendSuccessNotification(activityName: activity.name)
                print("Handle done: confirmation notification sent 📩 ")
            } catch let error {
                print(error)

            }
        }
    }
}
