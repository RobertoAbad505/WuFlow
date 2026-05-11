//
//  Router.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/11/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class Router: ObservableObject {
    
    @Published var selectedTab: AppTab = .home
    
    @Published var homePath = NavigationPath()
    @Published var insightsPath = NavigationPath()
    @Published var settingsPath = NavigationPath()
    @Published var activitiesPath = NavigationPath()
    
    func navigate(to route: AppRoute) {
        switch route {
        case .home:
            selectedTab = .home
            homePath = NavigationPath()
        case .activityList:
            //first we select the tab of the main container
            selectedTab = .activityList
            //activities list is already at tab root, so no need to add a route to activitiesPath
            //but we can reset this path history
            activitiesPath = NavigationPath()
        case .activityDetail(_):
            selectedTab = .activityList
            activitiesPath.append(route)
        case .addActivity:
            selectedTab = .activityList
            activitiesPath.append(route)
        case .addProgress(_):
            selectedTab = .activityList
            activitiesPath.append(route)
        case .insights:
            selectedTab = .insights
            insightsPath.append(route)
        case .settings:
            selectedTab = .settings
            settingsPath.append(route)
        }
    }
    func handleDeepLink(_ url: URL) {
        print("OPEN FROM EXTERNAL URL: \(url)")
        guard url.scheme == "wuflow" else {
            //no valid scheme, just ignore
            return
        }
        
        guard let host = url.host else {
            //no host available, ignore
            return
        }
        switch host {
        case "activities":
            navigate(to: .activityList)
        case "insights":
            navigate(to: .insights)
        case "settings":
            navigate(to: .settings)
        case "addProgress":
            navigate(to: .addProgress(nil))
        default:
            navigate(to: .home)
        }
    }
}
