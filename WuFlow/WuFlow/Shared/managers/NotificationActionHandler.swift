//
//  NotificationActionHandler.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/8/26.
//

import Foundation
import SwiftData

final class NotificationActionHandler {

    static let shared = NotificationActionHandler()

    private init() {}

    func handleDone(activityId: String) {

        let context = ModelContext(
            DataStore.shared.container
        )

        do {
            print(" NotificationActionHandler: HANDLE DONE ACTION")
            let uuid = UUID(uuidString: activityId)

            let descriptor = FetchDescriptor<Activity>()

            let activities = try context.fetch(descriptor)
            print("Searching for : \(activityId)")
            guard let activity = activities.first(
                where: { $0.id == uuid }
            ) else {
                print("❌ Activity not found")
                return
            }
            print("✅ Found Activity")
            
            // Duplicate protection
            let fiveMinutesAgo = Date().addingTimeInterval(-300)

            let progressDescriptor = FetchDescriptor<ProgressRecord>()

            let progressRecords = try context.fetch(progressDescriptor)
            
            let recentRecord = progressRecords.first { record in
                record.activity?.id == activity.id &&
                record.date >= fiveMinutesAgo
            }
            if recentRecord != nil {
                print("⚠️ Duplicate prevented")
                return
            }
            
            let progress = ProgressRecord(value: reminderIncrement(for: activity),
                                          date: .now,
                                          source: .reminder,
                                          activity: activity)
            progress.activity = activity
            context.insert(progress)
            try context.save()
            print("✅ Progress recorded")
            print("Activity:", activity.name)
            NotificationManager.shared
                .sendSuccessNotification(
                    activityName: activity.name
                )
        } catch {

            print("❌ Fetch failed:", error)
        }
    }
    private func reminderIncrement(
        for activity: Activity
    ) -> Double {

        switch activity.unitType {

        case .sessions:
            return 1

        default:
            return 1
        }
    }
}
