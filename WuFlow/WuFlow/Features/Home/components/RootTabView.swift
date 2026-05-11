//
//  RootTabView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/14/26.
//

import SwiftUI

struct RootTabView: View {
    
    @EnvironmentObject private var router: Router
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeNavigationView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)
            
            ActivitiesNavigationView()
                .tabItem {
                    Label("Activities", systemImage: "list.bullet")
                }
                .tag(AppTab.activityList)
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(AppTab.insights)
            
            SettingsNavigationView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(.green.opacity(0.7))
    }
}

#Preview {
    RootTabView()
}
