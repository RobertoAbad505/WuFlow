//
//  ProgressAnalytics.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/4/26.
//

import Foundation

struct ProgressAnalytics {
    
    static func filterRecords(
        _ records: [ProgressRecord],
        by filter: TimeFilter
    ) -> [ProgressRecord] {
        
        guard let range = filter.dateRange() else {
            return records // .all case
        }
        
        return records.filter {
            $0.date >= range.start && $0.date < range.end
        }
    }
    
    static func groupByDay(
        _ records: [ProgressRecord]
    ) -> [Date: Double] {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: records) {
            calendar.startOfDay(for: $0.date)
        }
        
        return grouped.mapValues {
            $0.reduce(0) { $0 + $1.value }
        }
    }
    
    static func makeChartData(
        from grouped: [Date: Double]
    ) -> [DailyProgress] {
        grouped
            .map { DailyProgress(date: $0.key, total: $0.value) }
            .sorted { $0.date < $1.date }
    }
}
