//
//  LifeArea.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//

import Foundation
import SwiftUI

enum LifeArea: String, CaseIterable, Codable {
    case health        // body, nutrition, sleep
    case mind          // meditation, mental clarity
    case growth        // learning, education, skills
    case work          // career, productivity, projects
    case social        // relationships, friends, family
    case leisure       // hobbies, fun, rest
}

extension LifeArea {
    
    var title: String {
        switch self {
        case .health: return "Health"
        case .mind: return "Mind"
        case .growth: return "Growth"
        case .work: return "Work"
        case .social: return "Social"
        case .leisure: return "Leisure"
        }
    }
    
    var iconName: String {
        switch self {
        case .health: return "heart.fill"
        case .mind: return "brain.head.profile"
        case .growth: return "book.fill"
        case .work: return "briefcase.fill"
        case .social: return "person.2.fill"
        case .leisure: return "leaf.fill"
        }
    }
    var color: Color {
        switch self {
        case .health: return .red
        case .mind: return .purple
        case .growth: return .blue
        case .work: return .orange
        case .social: return .green
        case .leisure: return .teal
        }
    }
}
