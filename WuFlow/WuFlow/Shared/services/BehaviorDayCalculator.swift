//
//  BehaviorDayCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/15/26.
//


import Foundation

final class BehaviorDayCalculator {

    func calculate(
        progressRecords: [ProgressRecord],
        observations: [ObservationRecord],
        from startDate: Date,
        to endDate: Date,
        calendar: Calendar = .current
    ) -> [BehaviorDay] {

        let groupedRecords = Dictionary(
            grouping: progressRecords.filter {
                $0.date >= startDate && $0.date < endDate
            }
        ) {
            calendar.startOfDay(for: $0.date)
        }

        let groupedIncidents = Dictionary(
            grouping: observations.filter {
                $0.kind == .incident &&
                $0.date >= startDate &&
                $0.date < endDate
            }
        ) {
            calendar.startOfDay(for: $0.date)
        }

        var days: [BehaviorDay] = []

        var currentDate = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        while currentDate < end {

            let records = groupedRecords[currentDate] ?? []
            let incidents = groupedIncidents[currentDate] ?? []

            days.append(
                BehaviorDay(
                    date: currentDate,
                    progressValue: records.reduce(0) {
                        $0 + $1.value
                    },
                    progressCount: records.count,
                    incidentCount: incidents.count
                )
            )

            currentDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: currentDate
            )!
        }

        return days
    }
}
