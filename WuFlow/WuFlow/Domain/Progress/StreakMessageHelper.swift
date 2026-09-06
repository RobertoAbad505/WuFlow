//
//  StreakMessageHelper.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/4/26.
//


struct StreakMessageHelper {

    static func message(
        count: Int,
        period: GoalPeriod
    ) -> String {
        switch count {
        case 0:
            return "Start your streak today"

        case 1...2:
            return "You're getting started"

        case 3...6:
            return "You're building consistency"

        default:
            return "You're on fire 🔥"
        }
    }
}
struct StreakFormatter {

    static func title(
        count: Int,
        period: GoalPeriod
    ) -> String {

        let unit: String

        switch period {
        case .daily:
            unit = count == 1 ? "day" : "days"

        case .weekly:
            unit = count == 1 ? "week" : "weeks"

        case .monthly:
            unit = count == 1 ? "month" : "months"
        }

        return "\(count) \(unit) streak"
    }

    static func message(for count: Int) -> String {
        switch count {
        case 0:
            return "Start your streak today"
        case 1...2:
            return "You're getting started"
        case 3...6:
            return "You're building consistency"
        default:
            return "You're on fire 🔥"
        }
    }
}
