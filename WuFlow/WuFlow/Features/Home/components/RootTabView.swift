//
//  RootTabView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/14/26.
//

import SwiftUI

struct RootTabView: View {
    
    var body: some View {
        TabView {            
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            NavigationStack {   // 👈 ADD THIS
                ActivityListView()
            }
            .tabItem {
                Label("Activities", systemImage: "list.bullet")
            }
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.green.opacity(0.7))
    }
}

#Preview {
    RootTabView()
}
