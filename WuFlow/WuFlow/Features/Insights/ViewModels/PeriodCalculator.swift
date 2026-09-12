//
//  PeriodCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/11/26.
//
import Foundation

enum ComparisonPeriod: Sendable {
    case days(Int)
}

final class PeriodCalculator {

    func comparison(
        period: ComparisonPeriod,
        endingAt endDate: Date = .now,
        calendar: Calendar = .current
    ) -> ComparisonPeriods {

        switch period {

        case .days(let days):

            let currentStart = calendar.date(
                byAdding: .day,
                value: -days,
                to: endDate
            )!

            let previousStart = calendar.date(
                byAdding: .day,
                value: -(days * 2),
                to: endDate
            )!

            return ComparisonPeriods(
                previous: DateRange(
                    start: previousStart,
                    end: currentStart
                ),
                current: DateRange(
                    start: currentStart,
                    end: endDate
                )
            )
        }
    }
}
