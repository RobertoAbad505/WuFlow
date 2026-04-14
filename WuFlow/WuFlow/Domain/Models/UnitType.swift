//
//  UnitType.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 3/31/26.
//

enum UnitType: String, Codable, CaseIterable {
    case minutes = "Minutes"
    case steps = "Steps"
    case sessions = "Sessions"
    case count = "Count"
    case pages = "Pages"
}
extension UnitType {
    func iconName() -> String {
        switch self {
        case .minutes: return "clock"
        case .steps: return "figure.stairs.circle"
        case .sessions: return "star.circle"
        case .count: return "plus.circle.dashed"
        case .pages: return "book.pages"
        }
    }
}
