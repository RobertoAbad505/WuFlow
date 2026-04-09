//
//  AppRouteEnum.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/6/26.
//

import Foundation

enum AppRoute: Hashable {
    case activityList
    case activityDetail(Activity)
    case addActivity
    case addProgress(Activity?)
    case insights
}
