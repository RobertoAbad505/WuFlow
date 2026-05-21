//
//  NotificationsView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/20/26.
//

import SwiftUI

struct NotificationsView: View {
    
    @AppStorage("notifications_enabled")
    private var notificationsEnabled: Bool = false

    @State private var permissionStatus: NotificationPermissionStatus = .notDetermined
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Notifications")
                .font(Font.title.weight(.bold))
            notificationsEnableToggle
            Button(action: {
                NotificationManager.shared.sendTestNotification()
            }, label: {
                Text("Send test notification")
                    .padding()
            })
            .background(.blue.opacity(0.5))
            .buttonStyle(.glass)
            Spacer()
        }
        .padding()
        .onAppear {
            refreshPermissionStatus()
        }
    }
    
    private func refreshPermissionStatus() {
        NotificationManager.shared.currentPermissionStatus { status in
            permissionStatus = status
        }
    }
    
    var notificationsEnableToggle: some View {
        Toggle(isOn: $notificationsEnabled, label: {
            Text("Notifications enabled")
        })
        .onChange(of: notificationsEnabled) { _, newValue in
            
            guard newValue else { return }
            
            NotificationManager.shared.currentPermissionStatus { status in
                
                switch status {
                    
                case .authorized:
                    print("✅ Notifications already enabled")
                    
                case .notDetermined:
                    
                    NotificationManager.shared.requestPermission { granted in
                        refreshPermissionStatus()
                        if !granted {
                            notificationsEnabled = false
                        }
                    }
                case .denied:
                    notificationsEnabled = false
                }
            }
        }
    }
}

#Preview {
    NotificationsView()
}
