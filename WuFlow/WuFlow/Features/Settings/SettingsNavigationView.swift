//
//  SettingsNavigationView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/11/26.
//

import SwiftUI

struct SettingsNavigationView: View {
    
    @EnvironmentObject private var router: Router
    
    var body: some View {
        NavigationStack(path: $router.settingsPath) {
            SettingsView()
                .navigationDestination(for: SettingsRoute.self) { type in
                    switch type {
                    case .notifications:
                        NotificationsView()
                    case .account:
                        Text("Account settings view - still in development")
                    case .appearance:
                        Text("Appearance view - still in development")
                    case .healtKitSettings:
                        HealtKitSettingsView()
                    case .locations:
                        LocationSettings()
                    }
                }
        }
    }
    
}

#Preview {
    SettingsNavigationView()
}
