//
//  DebugEvent.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/15/26.
//
import Foundation
import SwiftUI

struct DebugEvent: Identifiable {

    let id = UUID()

    let date = Date()

    let message: String
    
    let level: DebugLevel
}
enum DebugLevel {

    case info

    case success

    case warning

    case error

}
extension DebugLevel {

    var icon: String {

        switch self {

        case .info:
            return "info.circle"

        case .success:
            return "checkmark.circle"

        case .warning:
            return "exclamationmark.triangle"

        case .error:
            return "xmark.octagon"
        }
    }
    var color: Color {        
        switch self {
        case .info:
            return .blue
        case .success:
            return .green
        case .warning:
            return .yellow
        case .error:
            return .red
        }
    }
}
