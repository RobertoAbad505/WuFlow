//
//  DateRange.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/11/26.
//
import Foundation

struct DateRange: Sendable {
    let start: Date
    let end: Date

    func contains(_ date: Date) -> Bool {
        date >= start && date < end
    }
}
