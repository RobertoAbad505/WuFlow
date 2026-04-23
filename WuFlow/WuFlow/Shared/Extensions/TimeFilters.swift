//
//  TimeFilters.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/4/26.
//

import Foundation

enum TimeFilter: CaseIterable {
    case last7Days
    case last30Days
    case all
}

extension TimeFilter {
    
    func dateRange() -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .last7Days:
            let start = calendar.date(byAdding: .day, value: -6, to: now)!
            return (calendar.startOfDay(for: start), now)
            
        case .last30Days:
            let start = calendar.date(byAdding: .day, value: -29, to: now)!
            return (calendar.startOfDay(for: start), now)
            
        case .all:
            return nil
        }
    }
}
