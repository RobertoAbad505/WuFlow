//
//  BehaviorCalendarData.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/16/26.
//


import Foundation

struct BehaviorCalendarData: Sendable {
    let days: [BehaviorDay]
    let positions: [CalendarDayPosition]
}