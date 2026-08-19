//
//  Activity+Progress.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/17/26.
//

import Foundation

extension Activity {    
    var goalDescription: String {
        "\(Int(goalValue)) \(measurement.displayName) \(goalPeriod.displayName)"
    }
    var suggestedIncrement: Double {

        if defaultIncrement > 0 {
            return defaultIncrement
        }

        switch measurement {

        case .session:
            return 1

        case .duration:
            return 10

        case .count:
            return 1000

        case .distance:
            return 1
        }
    }
}

