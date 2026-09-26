//
//  BehaviorDay.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/15/26.
//


import Foundation

struct BehaviorDay: Identifiable, Sendable {
    let date: Date
    let progressValue: Double
    let progressCount: Int
    let incidentCount: Int

    var id: Date { date }
}
extension BehaviorDay {

    func state(
        for mode: BehaviorCalendarMode
    ) -> BehaviorDayState {

        switch mode {
        case .progress:
            return progressCount > 0
                ? .progress
                : .empty

        case .incidents:
            return incidentCount > 0
                ? .incident
                : .empty
        }
    }
}
