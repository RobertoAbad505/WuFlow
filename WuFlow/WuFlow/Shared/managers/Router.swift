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
    
    func navigate(to route: HomeRoute) {
        switch route {
        case .home:
            selectedTab = .home
        }
    }
    func navigate(to route: ActivitiesRoute) {
        selectedTab = .activityList
        switch route {
        case .activitiesList:
            activitiesPath = NavigationPath()
        case .detail(_):
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
        }
    }
    //navigate to settings destinations
    func navigate(to route: SettingsRoute) {
        selectedTab = .settings
        switch route {
            case .notifications:
            settingsPath.append(route)
        case .account:
            settingsPath.append(route)
        case .appearance:
            settingsPath.append(route)
        case .healtKitSettings:
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
            navigate(to: .activitiesList)
        case "insights":
            navigate(to: .insights(nil))
        case "settings":
            selectedTab = .settings
        case "addProgress":
            navigate(to: .addProgress(nil))
        default:
            navigate(to: .home)
        }
    }
}
