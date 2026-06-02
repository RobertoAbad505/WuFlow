//
//  ActivitiesNavigationView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/11/26.
//

import SwiftUI

struct ActivitiesNavigationView: View {

    @EnvironmentObject private var router: Router

    var body: some View {
        NavigationStack(path: $router.activitiesPath) {
            ActivityListView()
                .navigationDestination(for: ActivitiesRoute.self) { route in
                    switch route {
                    case .detail(let activity):
                        ActivityDetailView(activity: activity)
                    case .addActivity:
                        CreateActivityView(mode: .create, onUpdate: {_ in})
                    case .addProgress:
                        AddActivityProgressView()
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

#Preview {
    ActivitiesNavigationView()
}
