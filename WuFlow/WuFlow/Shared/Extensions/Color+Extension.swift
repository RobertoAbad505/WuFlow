//
//  Color+Extension.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/14/26.
//
import SwiftUI

extension Color {
    static func colorForActivity(_ activity: Activity) -> Color {
        // simple variation
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        return colors[abs(activity.name.hashValue) % colors.count]
    }
}
