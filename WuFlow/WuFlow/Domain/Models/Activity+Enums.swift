//
//  Activity 2.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/17/26.
//

import Foundation

enum ActivityTypes: String, Codable, CaseIterable {
    case increase// build / do more
    case maintain// stay consistent (Wu Wei)
    case decrease// reduce / avoid
    
    var name: String {
        switch self {
            case .increase: return "🌱 Build"
            case .decrease: return "🔥 Reduce"
            case .maintain: return "🌊 Flow"
        }
    }
}
enum ReminderType: String, Codable, CaseIterable {
    case scheduled
    case contextual
}
enum ReminderPreset: String, Codable, CaseIterable  {
    case morning = "☀️ Morning"
    case midday  = "🌤 Midday"
    case evening = "🌙 Evening"
    case custom = "🕓 Custom"
}
enum ReminderTone: String, Codable, CaseIterable {
    case light
    case heavy
    case gentle
}
enum MeasurementType: String, Codable, CaseIterable {

    case session
    case duration
    case count
    case distance

    var displayName: String {
        switch self {
        case .session: "Sessions"
        case .duration: "Minutes"
        case .count: "Count"
        case .distance: "Distance"
        }
    }
}
enum GoalPeriod: String, Codable, CaseIterable {

    case daily
    case weekly
    case monthly

    var displayName: String {
        rawValue.capitalized
    }
}
