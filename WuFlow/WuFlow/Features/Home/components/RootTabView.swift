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
            
            ActivityListView()
                .tabItem {
                    Label("Activities", systemImage: "square.grid.2x2.fill")
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
        .tint(.green)
    }
}

#Preview {
    RootTabView()
}
