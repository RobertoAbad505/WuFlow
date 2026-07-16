//
//  AppRoutes.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/6/26.
//

import Foundation

enum HomeRoute: Hashable {
    case home
}

enum ActivitiesRoute: Hashable {
    case activitiesList
    case detail(Activity)
    case addActivity
    case addProgress(Activity?)
    case insights(Activity?)
}
enum SettingsRoute: Hashable {
//    case settingsLanding
    case notifications
    case account
    case appearance
    case locations
    case healtKitSettings
}
