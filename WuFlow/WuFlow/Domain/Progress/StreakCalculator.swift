//
//  StreakCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 8/19/26.
//
import Foundation

final class StreakCalculator {

    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    private func periodInterval(
        for period: GoalPeriod,
        containing date: Date
    ) -> DateInterval? {

        switch period {
        case .daily:
            return calendar.dateInterval(
                of: .day,
                for: date
            )

        case .weekly:
            return calendar.dateInterval(
                of: .weekOfYear,
                for: date
            )

        case .monthly:
            return calendar.dateInterval(
                of: .month,
                for: date
            )
        }
    }
    private func periodCompleted(
        activity: Activity,
        date: Date,
        records: [ProgressRecord]
    ) -> Bool {

        let total = total(
            for: activity.goalPeriod,
            date: date,
            records: records
        )

        return total >= activity.goalValue
    }
    private func total(
        for period: GoalPeriod,
        date: Date,
        records: [ProgressRecord]
    ) -> Double {

        guard let interval = periodInterval(
            for: period,
            containing: date
        ) else {
            return 0
        }

        return records
            .filter {
                interval.contains($0.date)
            }
            .reduce(0) {
                $0 + $1.value
            }
    }
    func activityStreak(
        _ activity: Activity,
        records: [ProgressRecord],
        now: Date = .now
    ) -> Int {

        var streak = 0
        var date = now

        // If the current period isn't complete yet,
        // start checking from the previous period.
        if !periodCompleted(
            activity: activity,
            date: date,
            records: records
        ) {
            guard let previous = previousPeriod(
                activity.goalPeriod,
                from: date
            ) else {
                return 0
            }

            date = previous
        }

        while periodCompleted(
            activity: activity,
            date: date,
            records: records
        ) {

            streak += 1

            guard let previous = previousPeriod(
                activity.goalPeriod,
                from: date
            ) else {
                break
            }

            date = previous
        }

        return streak
    }
    private func previousPeriod(
        _ period: GoalPeriod,
        from date: Date
    ) -> Date? {

        switch period {
        case .daily:
            return calendar.date(
                byAdding: .day,
                value: -1,
                to: date
            )

        case .weekly:
            return calendar.date(
                byAdding: .weekOfYear,
                value: -1,
                to: date
            )

        case .monthly:
            return calendar.date(
                byAdding: .month,
                value: -1,
                to: date
            )
        }
    }

    private func total(
        for date: Date,
        grouped: [Date: [ProgressRecord]]
    ) -> Double {

        grouped[
            calendar.startOfDay(for: date)
        ]?
        .reduce(0) { $0 + $1.value } ?? 0
    }
    
    func globalStreak(records: [ProgressRecord]) -> Int {
        let grouped = Dictionary(grouping: records) {
            calendar.startOfDay(for: $0.date)
        }

        var streak = 0
        var date = Date()

        while true {
            let day = calendar.startOfDay(for: date)

            guard grouped[day] != nil else {
                break
            }

            streak += 1

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: date
            ) else {
                break
            }

            date = previousDay
        }

        return streak
    }
}
