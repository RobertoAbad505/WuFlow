//
//  HomeNavigationView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/11/26.
//

import SwiftUI

struct HomeNavigationView: View {
    
    @EnvironmentObject private var router: Router
    
    var body: some View {
        NavigationStack(path: $router.homePath) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    
                    switch route {

                    case .activityList:
                        ActivityListView()

                    case .activityDetail(let activity):
                        ActivityDetailView(activity: activity)

                    case .addActivity:
                        CreateActivityView(mode: .create)

                    case .addProgress(let activity):
                        AddActivityProgressView(activity: activity)

                    case .insights:
                        InsightsView()

                    case .settings:
                        Text("Settings")

                    case .home:
                        HomeView()
                    }
                }
        }
    }
}

#Preview {
    HomeNavigationView()
}
