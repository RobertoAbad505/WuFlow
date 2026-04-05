//
//  DailyProgress.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/4/26.
//

import Foundation

struct DailyProgress: Identifiable {
    let id = UUID()
    let date: Date
    let total: Double
}
