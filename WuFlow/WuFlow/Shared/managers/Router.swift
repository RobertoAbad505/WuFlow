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
    @Published var path = NavigationPath()
    
    func navigate(to route: AppRoute) {
        switch route {
        case .home:
            selectedTab = .home
            reset()            
        case .activityList:
            //first we select the tab of the main container
            selectedTab = .activityList
            
            //then we add the destination
            path.append(route)
            
        case .activityDetail(_):
            selectedTab = .activityList
            path.append(route)
        case .addActivity:
            selectedTab = .home
            path.append(route)
        case .addProgress(_):
            selectedTab = .home
            path.append(route)
        case .insights:
            selectedTab = .insights
            path.append(route)
        case .settings:
            selectedTab = .settings
            path.append(route)
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
        default:
            navigate(to: .home)
        }
    }
    func popRoute() {
        path.removeLast()
    }
    func reset() {
        path = NavigationPath()
    }
}
