//
//  BehaviorCalendarDataCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/16/26.
//


import Foundation

final class BehaviorCalendarDataCalculator {

    private let behaviorDayCalculator =
        BehaviorDayCalculator()

    private let behaviorCalendarCalculator =
        BehaviorCalendarCalculator()

    func calculate(
        progressRecords: [ProgressRecord],
        observations: [ObservationRecord],
        from startDate: Date,
        to endDate: Date,
        calendar: Calendar = .current
    ) -> BehaviorCalendarData {

        let days = behaviorDayCalculator.calculate(
            progressRecords: progressRecords,
            observations: observations,
            from: startDate,
            to: endDate,
            calendar: calendar
        )

        let positions = behaviorCalendarCalculator.positions(
            for: days,
            calendar: calendar
        )

        return BehaviorCalendarData(
            days: days,
            positions: positions
        )
    }
}