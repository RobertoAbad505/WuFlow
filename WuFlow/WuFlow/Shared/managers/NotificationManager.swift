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
    
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        
        print("🔥 Foreground notification received")
        
        return [.banner, .sound]
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
    
    func sendTestNotification(_ title: String, _ body: String) {
        
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = body
        content.sound = .default
        
        // Trigger after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current()
            .add(request) { error in                
                if let error {
                    print("❌ Failed to schedule notification:", error)
                } else {
                    print("✅ Test notification scheduled")
                }
            }
    }
}

enum NotificationPermissionStatus {
    case notDetermined
    case denied
    case authorized
}
