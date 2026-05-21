//
//  NotificationManager.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/20/26.
//

import Foundation
import UserNotifications
import UIKit

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
    
    func sendTestNotification() {
        
        let content = UNMutableNotificationContent()
        
        content.title = "Te estoy viendoooo👀"
        content.body = "Clic para poner Rosa Pastel y chingate la rutina completa"
        content.sound = .defaultCritical
        
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
