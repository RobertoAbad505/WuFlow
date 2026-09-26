//
//  Calendar+Extension.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/16/26.
//

import Foundation

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        dateInterval(
            of: .month,
            for: date
        )?.start ?? date
    }
}
