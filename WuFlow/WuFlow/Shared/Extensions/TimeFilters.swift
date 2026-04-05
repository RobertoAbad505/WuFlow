//
//  TimeFilters.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/4/26.
//

import Foundation

enum TimeFilter: CaseIterable {
    case all
    case today
    case yesterday
    case currentWeek
    case lastWeek
    case currentMonth
    case lastMonth
}

extension TimeFilter {
    
    func dateRange(from calendar: Calendar = .current) -> (start: Date, end: Date)? {
        let now = Date()
        
        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
            
        case .yesterday:
            let todayStart = calendar.startOfDay(for: now)
            let start = calendar.date(byAdding: .day, value: -1, to: todayStart)!
            return (start, todayStart)
            
        case .currentWeek:
            let interval = calendar.dateInterval(of: .weekOfYear, for: now)!
            return (interval.start, interval.end)
            
        case .lastWeek:
            let currentWeek = calendar.dateInterval(of: .weekOfYear, for: now)!
            let start = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek.start)!
            let end = currentWeek.start
            return (start, end)
            
        case .currentMonth:
            let interval = calendar.dateInterval(of: .month, for: now)!
            return (interval.start, interval.end)
            
        case .lastMonth:
            let currentMonth = calendar.dateInterval(of: .month, for: now)!
            let start = calendar.date(byAdding: .month, value: -1, to: currentMonth.start)!
            let end = currentMonth.start
            return (start, end)
        case .all:
            return nil
        }
    }
}
