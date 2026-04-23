//
//  ActivityInsights.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/23/26.
//
import Foundation

struct ActivityInsights {
    
    static func activeDaysLast7(records: [ProgressRecord]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        let last7Days = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: now)
        }
        
        let grouped = Dictionary(grouping: records) {
            calendar.startOfDay(for: $0.date)
        }
        
        return last7Days.filter {
            grouped[calendar.startOfDay(for: $0)] != nil
        }.count
    }
}
