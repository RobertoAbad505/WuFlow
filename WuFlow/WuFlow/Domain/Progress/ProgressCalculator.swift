//
//  ProgressCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 8/10/26.
//
import Foundation
import SwiftData

final class ProgressCalculator {

    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    // MARK: - Public

    func progress(
        for activity: Activity,
        records: [ProgressRecord],
        now: Date = .now
    ) -> ProgressSummary {

        let currentRecords = currentPeriodRecords(
            records,
            period: activity.goalPeriod,
            now: now
        )

        let value = currentPeriodProgress(
            records: currentRecords,
            aggregation: activity.trackingType.aggregation
        )

        let ratio = progressRatio(
            currentValue: value,
            goal: activity.goalValue
        )

        let status = status(
            currentValue: value,
            goal: activity.goalValue
        )

        let remaining = max(
            activity.goalValue - value,
            0
        )

        return ProgressSummary(
            value: value,
            goal: activity.goalValue,
            ratio: ratio,
            percentage: Int(ratio * 100),
            remaining: remaining,
            status: status,
            records: currentRecords,
            completed: status == .completed || status == .exceeded
        )
    }
}

// MARK: - Private

private extension ProgressCalculator {

    private func currentPeriodRecords(
        _ records: [ProgressRecord],
        period: GoalPeriod,
        now: Date
    ) -> [ProgressRecord] {

        records.filter {
            isRecord(
                $0,
                inside: period,
                now: now
            )
        }
    }

    func currentPeriodProgress(
        records: [ProgressRecord],
        aggregation: ProgressAggregation
    ) -> Double {

        switch aggregation {

        case .sum:
            return records.reduce(0) { partial, record in
                partial + record.value
            }

        case .latest:
            return records
                .max(by: { $0.date < $1.date })?
                .value ?? 0
        }
    }

    func progressRatio(
        currentValue: Double,
        goal: Double
    ) -> Double {

        guard goal > 0 else {
            return 0
        }

        return min(currentValue / goal, 1.0)
    }

    func status(
        currentValue: Double,
        goal: Double
    ) -> ActivityStatus {

        guard currentValue > 0 else {
            return .notStarted
        }

        if currentValue < goal {
            return .inProgress
        }

        if currentValue == goal {
            return .completed
        }

        return .exceeded
    }

    func isRecord(
        _ record: ProgressRecord,
        inside period: GoalPeriod,
        now: Date
    ) -> Bool {

        switch period {

        case .daily:
            return calendar.isDate(
                record.date,
                inSameDayAs: now
            )

        case .weekly:
            return calendar.isDate(
                record.date,
                equalTo: now,
                toGranularity: .weekOfYear
            )

        case .monthly:
            return calendar.isDate(
                record.date,
                equalTo: now,
                toGranularity: .month
            )
        }
    }
    private func currentPeriod(
        for goalPeriod: GoalPeriod,
        now: Date
    ) -> DateInterval {

        switch goalPeriod {

        case .daily:
            let start = calendar.startOfDay(for: now)

            let end = calendar.date(
                byAdding: .day,
                value: 1,
                to: start
            )!

            return DateInterval(
                start: start,
                end: end
            )

        case .weekly:
            let interval = calendar.dateInterval(
                of: .weekOfYear,
                for: now
            )!

            return interval

        case .monthly:
            let interval = calendar.dateInterval(
                of: .month,
                for: now
            )!

            return interval
        }
    }
}

struct ActivitySummary: Identifiable {

    let activity: Activity
    let progress: ProgressSummary

    var id: UUID {
        activity.id
    }
}
