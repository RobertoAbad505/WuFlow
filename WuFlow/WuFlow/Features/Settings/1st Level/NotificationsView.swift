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
    
    
    @State private var title: String = "WuFlow 🌿"
    @State private var bodyContent: String = "A small pause for Meditation 🧘‍♂️"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Notifications")
                .font(Font.title.weight(.bold))
            notificationsEnableToggle
            notificationTester
        }
        .padding()
        .onAppear {
            refreshPermissionStatus()
        }
    }
    var notificationTester: some View {
        VStack {
            TextField("Title:", text: $title)
            TextField("Body: ", text: $bodyContent)
            Button(action: {
                NotificationManager.shared.sendTestNotification(title, bodyContent)
            }, label: {
                Text("Send test notification")
                    .padding()
            })
            .buttonStyle(.glass)
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
        .padding(.bottom)
        .onChange(of: notificationsEnabled) { _, newValue in
            
            guard newValue else { return }
            
            if !newValue {
                NotificationManager.shared.removeAllWuFlowReminders()
            }
            
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
