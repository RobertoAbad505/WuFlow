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
                .navigationDestination(for: ActivitiesRoute.self) { route in
                    switch route {
                        
                    case .activitiesList:
                        ActivityListView()

                    case .detail(let activity):
                        ActivityDetailView(activity: activity)

                    case .addActivity:
                        CreateActivityView(mode: .create)

                    case .addProgress(let activity):
                        AddActivityProgressView(activity: activity)
                    case .insights(_):
                        Text("Insights still in development")
                    }
                }
        }
    }
}

#Preview {
    HomeNavigationView()
}
