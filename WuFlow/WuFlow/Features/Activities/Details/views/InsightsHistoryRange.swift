//
//  InsightsHistoryRange.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 11/25/26.
//


import Foundation

enum InsightsHistoryRange: String, CaseIterable, Identifiable {
    case last7Days
    case last30Days
    case last90Days
    case selectedMonth
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .last7Days: "7D"
        case .last30Days: "30D"
        case .last90Days: "90D"
        case .selectedMonth: "Month"
        case .all: "All"
        }
    }
}
