//
//  CalendarMonthNavigator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/17/26.
//
import Foundation

struct CalendarMonthNavigator {
    let calendar: Calendar

    func previousMonth(from date: Date) -> Date? {
        calendar.date(
            byAdding: .month,
            value: -1,
            to: date
        )
    }

    func nextMonth(from date: Date) -> Date? {
        calendar.date(
            byAdding: .month,
            value: 1,
            to: date
        )
    }
}
