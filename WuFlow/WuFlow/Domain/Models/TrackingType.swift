//
//  TrackingType.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 3/31/26.
//

enum TrackingType: String, Codable, CaseIterable {
    case manual
    case healthSteps
    case healthWorkout
    case location
    case reminder
}
extension TrackingType {

    var title: String {
        switch self {

        case .manual:
            return "Manual"

        case .healthSteps:
            return "HealthKit Steps"

        case .healthWorkout:
            return "HealthKit Workouts"

        case .location:
            return "Location"

        case .reminder:
            return "Reminder Actions"
        }
    }

    var description: String {
        switch self {

        case .manual:
            return "Progress is recorded manually."

        case .healthSteps:
            return "Progress is synced from Apple Health step count."

        case .healthWorkout:
            return "Progress is synced from Apple Health workouts."

        case .location:
            return "Progress is detected from location visits."

        case .reminder:
            return "Progress can be added directly from reminders."
        }
    }

    var icon: String {
        switch self {
        case .manual:
            return "square.and.pencil"

        case .healthSteps:
            return "figure.walk"

        case .healthWorkout:
            return "figure.run"

        case .location:
            return "location.fill"

        case .reminder:
            return "bell.badge.fill"
        }
    }
}
