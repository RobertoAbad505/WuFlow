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
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)
            
            NavigationStack {   // 👈 ADD THIS
                ActivityListView()
            }
            .tabItem {
                Label("Activities", systemImage: "list.bullet")
            }
            .tag(AppTab.activityList)
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(AppTab.insights)
            
            Text("Settings")
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
