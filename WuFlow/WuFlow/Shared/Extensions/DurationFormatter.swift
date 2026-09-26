//
//  DurationFormatter.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/14/26.
//


import Foundation

enum DurationFormatter {

    static func string(from duration: TimeInterval) -> String {
        let totalSeconds = max(Int(duration), 0)

        let days = totalSeconds / 86_400
        let hours = (totalSeconds % 86_400) / 3_600
        let minutes = (totalSeconds % 3_600) / 60

        if days > 0 {
            if hours > 0 {
                return "\(days)d \(hours)h"
            }

            return "\(days)d"
        }

        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            }

            return "\(hours)h"
        }

        return "\(minutes)m"
    }
}