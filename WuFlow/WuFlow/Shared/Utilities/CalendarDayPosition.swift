//
//  CalendarDayPosition.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/15/26.
//


import Foundation

struct CalendarDayPosition: Identifiable, Sendable {
    let day: BehaviorDay?
    let weekIndex: Int
    let weekdayIndex: Int

    var id: Date? {
        day?.date ?? nil
    }
}
