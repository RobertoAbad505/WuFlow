//
//  NotificationManager.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/20/26.
//

import Foundation
import UserNotifications
import UIKit

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    private let actionHandler: NotificationActionHandler

   init(actionHandler: NotificationActionHandler) {
       self.actionHandler = actionHandler
       super.init()
   }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        
        print("🔥 Foreground notification received")
        return [.banner, .sound]
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo =
            response.notification.request.content.userInfo
        
        let activityId =
            userInfo["activityId"] as? String ?? "Unknown"
        
        switch response.actionIdentifier {
            
        case "DONE_ACTION":
            actionHandler.handleDone(activityId: activityId)
            print("✅ DONE pressed")
            print("Activity ID:", activityId)
            
        case "LATER_ACTION":
            print("⏰ LATER pressed")
            print("Activity ID:", activityId)
            
        default:
            print("📲 Notification opened")
            print("Action identifier:", response.actionIdentifier)
            print("Activity ID:", activityId)
        }
    }
}

final class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    
    func openSystemSettings() {
        
        guard let url = URL(
            string: UIApplication.openSettingsURLString
        ) else { return }
        
        UIApplication.shared.open(url)
    }
    
    func currentPermissionStatus(completion: @escaping (NotificationPermissionStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: NotificationPermissionStatus
            
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                status = .authorized
            case .denied:
                status = .denied
            case .notDetermined:
                status = .notDetermined
            @unknown default:
                status = .notDetermined
            }
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { granted, error in
                
                if let error {
                    print("❌ Notification permission error:", error)
                }
                
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
    }
    
    func sendTestNotification(_ title: String = "WuFlow 🌿", _ body: String) {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
        sendNotification(title, body, "B8516AD4-3C7E-40E9-AC77-0BF8E015022E")
        
    }
    func sendGeoFenceNotification(activity: Activity, event: RegionEvent) {
        // 2. Make sure reminders enabled
        guard activity.remindersEnabled else {
            print("⚠️ Reminders DISABLED")
            return
        }
        sendNotification("WuFlow 🌿 - GeoFence crossed",
                         event.notificationBody(for: activity),
                         activity.id.uuidString)
    }
    
    func scheduleReminder(for activity: Activity) {
        
        // 1. Remove old reminder first
        cancelReminder(for: activity)
        
        // 2. Make sure reminders enabled
        guard activity.remindersEnabled else {
            print("⚠️ Reminders DISABLED")
            return
        }
        
        //5. Create repeating trigger
        let trigger = UNCalendarNotificationTrigger (
            dateMatching: reminderDateComponents(for: activity),
            repeats: true
        )
        sendNotification("WuFlow 🌿",
                         reminderBody(for: activity),
                         activity.id.uuidString,
                         trigger,
                         NotificationAction.activityReminder
        )
    }
    func sendNotification(_ title: String,
                          _ body: String,
                          _ activityId: String,
                          _ scheduled: UNCalendarNotificationTrigger? = nil,
                          _ category: String? = NotificationAction.activityReminder) {
        
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = body
        content.sound = .default
        
        content.categoryIdentifier = category ?? NotificationAction.activityReminder
        content.userInfo = [
            "activityId": "\(activityId)"
        ]
        
        // Trigger after 4 seconds
        let trigger =  UNTimeIntervalNotificationTrigger(
            timeInterval: 4,
            repeats: false
        )
        // 6. Stable identifier
        let identifier = "activity_\(activityId)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: scheduled ?? trigger
        )
        
        UNUserNotificationCenter.current()
            .add(request) { error in
                if let error {
                    print("❌ Failed to schedule notification:", error)
                } else {
                    print("✅ Notification scheduled")
                }
            }
    }
    private func reminderDateComponents(for activity: Activity) -> DateComponents {
        
        switch activity.reminderPreset {
        case .morning:
            return DateComponents(hour: 8, minute: 0)
        case .midday:
            return DateComponents(hour: 13, minute: 0)
        case .evening:
            return DateComponents(hour: 20, minute: 0)
        case .custom:
            guard let reminderTime = activity.reminderTime else {
                
                // fallback
                return DateComponents(
                    hour: 20,
                    minute: 0
                )
            }
            let calendar = Calendar.current
            
            return calendar.dateComponents(
                [.hour, .minute],
                from: reminderTime
            )
        }
    }
    private func reminderBody(
        for activity: Activity
    ) -> String {
        
        switch activity.reminderPreset {
            
        case .morning:
            return "Start your day with \(activity.name)."
            
        case .midday:
            return "A small pause for \(activity.name)."
            
        case .evening:
            return "Would tonight be a good moment for \(activity.name)?"
            
        case .custom:
            return "A reminder for \(activity.name)."
        }
    }
    func cancelReminder(for activity: Activity) {
        
        let identifier = "activity_\(activity.id.uuidString)"
        
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )
        
        print("🗑 Reminder removed for \(activity.name)")
    }
    func printPendingNotifications() {
        
        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in
                print("📬 Pending notifications:")
                for request in requests {
                    print("-------------------")
                    print("Title:", request.content.title)
                    print("Body:", request.content.body)
                    print("RequestID:", request.identifier)
                    print("Category:", request.content.categoryIdentifier)
                }
            }
    }
    
    func syncReminders(for activities: [Activity]) {
        
        removeAllWuFlowReminders()
        
        for activity in activities {
            
            guard activity.remindersEnabled else {
                continue
            }
            
            scheduleReminder(for: activity)
        }
        
        print("🔄 Reminder sync completed")
        printPendingNotifications()
    }
    func removeAllWuFlowReminders() {
        
        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in
                
                let identifiers = requests
                    .filter { $0.content.title == "WuFlow 🌿" }
                    .map(\.identifier)
                
                UNUserNotificationCenter.current()
                    .removePendingNotificationRequests(
                        withIdentifiers: identifiers
                    )
                
                print("🗑 Removed \(identifiers.count) reminders")
            }
    }
    func registerNotificationCategories() {
        
        let doneAction = UNNotificationAction(
            identifier: NotificationAction.done,
            title: "Done ✅",
            options: []
        )
        
        let laterAction = UNNotificationAction(
            identifier: NotificationAction.later,
            title: "Later ⏰",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: NotificationAction.activityReminder,
            actions: [
                doneAction,
                laterAction
            ],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current()
            .setNotificationCategories([category])
        
        print("✅ Notification categories registered")
    }
    func sendSuccessNotification(
        activityName: String
    ) {

        let messages = [
            "Small steps matter 🌱",
            "Consistency beats intensity 🌿",
            "Another step forward ✨",
            "Progress recorded 💪"
        ]
        let content = UNMutableNotificationContent()

        content.title = "🌿 Nice work"

        content.body = messages.randomElement() ?? "Progress recorded"

        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current()
            .add(request)
    }
}

enum NotificationPermissionStatus {
    case notDetermined
    case denied
    case authorized
}
private enum NotificationAction {
    
    static let done = "DONE_ACTION"
    static let later = "LATER_ACTION"
    
    static let activityReminder = "ACTIVITY_REMINDER"
}
