//
//  SettingsView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/20/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(Font.body.weight(.bold))            
            List {
                
                NavigationLink(value: SettingsRoute.notifications) {
                    Label("Notifications", systemImage: "bell")
                }
                
                NavigationLink(value: SettingsRoute.account) {
                    Label("Account", systemImage: "person")
                }
                
                NavigationLink(value: SettingsRoute.appearance) {
                    Label("Appearance", systemImage: "eye")
                }
                NavigationLink(value: SettingsRoute.healtKitSettings) {
                    Label("Healt Kit Settings", systemImage: "figure.cooldown")
                }
            }
            
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
