//
//  ActivityViewModel.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import Combine
import Foundation


final class ActivityViewModel: ObservableObject {
        
    init() {
        
    }
    
    func makeChartData(from grouped: [Date: Double]) -> [DailyProgress] {
        grouped
            .map { DailyProgress(date: $0.key, total: $0.value) }
            .sorted { $0.date < $1.date }
    }
}
