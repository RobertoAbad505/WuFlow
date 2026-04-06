//
//  QuickActions.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/5/26.
//

import Foundation
struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let action: () -> Void
}
