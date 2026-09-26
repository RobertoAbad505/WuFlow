//
//  BehaviorCalendarCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/15/26.
//
import Foundation

final class BehaviorCalendarCalculator {

    func positions(
        for days: [BehaviorDay],
        calendar: Calendar = .current
    ) -> [CalendarDayPosition] {

        guard let firstDay = days.first else {
            return []
        }

        let firstDate = calendar.startOfDay(
            for: firstDay.date
        )

        guard let firstWeekStart = calendar.dateInterval(
            of: .weekOfYear,
            for: firstDate
        )?.start else {
            return []
        }

        let firstWeekday = calendar.component(
            .weekday,
            from: firstDate
        )

        let leadingEmptyDays =
            (firstWeekday - calendar.firstWeekday + 7) % 7

        var positions: [CalendarDayPosition] = []

        for index in 0..<leadingEmptyDays {
            positions.append(
                CalendarDayPosition(
                    day: nil,
                    weekIndex: 0,
                    weekdayIndex: index
                )
            )
        }

        for day in days {
            let date = calendar.startOfDay(
                for: day.date
            )

            let weekday = calendar.component(
                .weekday,
                from: date
            )

            let weekdayIndex =
                (weekday - calendar.firstWeekday + 7) % 7

            let daysFromFirstWeek = calendar.dateComponents(
                [.day],
                from: firstWeekStart,
                to: date
            ).day ?? 0

            let weekIndex = daysFromFirstWeek / 7

            positions.append(
                CalendarDayPosition(
                    day: day,
                    weekIndex: weekIndex,
                    weekdayIndex: weekdayIndex
                )
            )
        }

        return positions
    }
}
