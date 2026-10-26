//
//  ActivityHistoryRange.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 10/26/26.
//
import Foundation

enum ActivityHistoryRange: String, CaseIterable, Identifiable {
    case last7Days
    case last30Days
    case selectedMonth

    var id: String { rawValue }

    var title: String {
        switch self {
        case .last7Days: "7D"
        case .last30Days: "30D"
        case .selectedMonth: "Month"
        }
    }
}
