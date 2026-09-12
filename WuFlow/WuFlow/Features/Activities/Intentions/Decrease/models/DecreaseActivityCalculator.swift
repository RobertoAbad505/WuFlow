//
//  DecreaseActivityCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/11/26.
//
import Foundation

final class DecreaseActivityCalculator {

    func calculate(
        activity: Activity,
        observations: [ObservationRecord],
        now: Date = .now
    ) -> DecreaseActivitySummary {

        let awarenessDuration = max(
            now.timeIntervalSince(activity.createdAt),
            0
        )

        let incidents = observations
            .filter {
                $0.activity.id == activity.id &&
                $0.kind == .incident
            }
            .sorted { $0.date < $1.date }

        let incidentCount = incidents.count

        let lastIncidentDate = incidents
            .map(\.date)
            .max()

        let currentIncidentFreeDuration: TimeInterval

        if let lastIncidentDate {
            currentIncidentFreeDuration = max(
                now.timeIntervalSince(lastIncidentDate),
                0
            )
        } else {
            currentIncidentFreeDuration = awarenessDuration
        }

        let longestIncidentFreeDuration = calculateLongestIncidentFreeDuration(
            activityStartDate: activity.createdAt,
            incidentDates: incidents.map(\.date),
            now: now
        )
        
        let incidentDates = incidents.map(\.date)

        let averageIncidentInterval = calculateAverageIncidentInterval(
            incidentDates: incidentDates
        )

        return DecreaseActivitySummary(
            awarenessDuration: awarenessDuration,
            incidentCount: incidentCount,
            currentIncidentFreeDuration: currentIncidentFreeDuration,
            longestIncidentFreeDuration: longestIncidentFreeDuration,
            averageIncidentInterval: averageIncidentInterval
        )
    }

    private func calculateLongestIncidentFreeDuration(
        activityStartDate: Date,
        incidentDates: [Date],
        now: Date
    ) -> TimeInterval {

        guard !incidentDates.isEmpty else {
            return max(
                now.timeIntervalSince(activityStartDate),
                0
            )
        }

        var longestDuration: TimeInterval = 0
        var previousDate = activityStartDate

        for incidentDate in incidentDates {
            let duration = max(
                incidentDate.timeIntervalSince(previousDate),
                0
            )

            longestDuration = max(
                longestDuration,
                duration
            )

            previousDate = incidentDate
        }

        let finalDuration = max(
            now.timeIntervalSince(previousDate),
            0
        )

        return max(
            longestDuration,
            finalDuration
        )
    }
    private func calculateAverageIncidentInterval(
        incidentDates: [Date]
    ) -> TimeInterval? {

        guard incidentDates.count >= 2 else {
            return nil
        }

        let intervals = zip(
            incidentDates,
            incidentDates.dropFirst()
        )
        .map { current, next in
            next.timeIntervalSince(current)
        }

        let total = intervals.reduce(0, +)

        return total / Double(intervals.count)
    }
}
