//
//  DailyProgress.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/4/26.
//

import Foundation

struct DailyProgress: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let total: Double
}
