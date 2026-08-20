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
    
    func activityStreak(
        _ activity: Activity,
        records: [ProgressRecord]
    ) -> Int {

        guard activity.goalPeriod == .daily else {
            return 0
        }

        return activityStreak(
            goalValue: activity.goalValue,
            records: records
        )
    }

    private func activityStreak(
        goalValue: Double,
        records: [ProgressRecord]
    ) -> Int {

        let grouped = Dictionary(grouping: records) {
            calendar.startOfDay(for: $0.date)
        }

        var date = Date()

        let todayTotal = total(
            for: date,
            grouped: grouped
        )

        if todayTotal < goalValue {
            date = calendar.date(
                byAdding: .day,
                value: -1,
                to: date
            )!
        }

        var streak = 0

        while true {
            let total = total(
                for: date,
                grouped: grouped
            )

            guard total >= goalValue else {
                break
            }

            streak += 1

            date = calendar.date(
                byAdding: .day,
                value: -1,
                to: date
            )!
        }

        return streak
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
}
