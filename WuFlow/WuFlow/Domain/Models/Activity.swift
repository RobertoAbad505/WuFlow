//
//  Activity.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 3/31/26.
//

import Foundation
import SwiftData

@Model
final class Activity {
    
    @Attribute(.unique)
    var id: UUID
    
    var name: String
    
    var unitType: UnitType
    
    var goalValue: Double
    
    var trackingType: TrackingType
    
    var createdAt: Date
    
    var isPinned: Bool = false
    var iconName: String = "circle.dotted"
    
    // Relationship
    @Relationship(deleteRule: .cascade)
    var progressRecords: [ProgressRecord] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        unitType: UnitType,
        goalValue: Double,
        trackingType: TrackingType,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.unitType = unitType
        self.goalValue = goalValue
        self.trackingType = trackingType
        self.createdAt = createdAt
    }
}
extension Activity {
    var todayProgress: Double {
        let calendar = Calendar.current
        
        return progressRecords
            .filter {
                calendar.isDateInToday($0.date)
            }
            .reduce(0) { $0 + $1.value }
    }
    var progressRatio: Double {
        guard goalValue > 0 else { return 0 }
        return min(todayProgress / goalValue, 1.0)
    }
    var progressPercentage: Int {
        Int(progressRatio * 100)
    }
    var status: ActivityStatus {
        if todayProgress == 0 {
            return .notStarted
        } else if todayProgress < goalValue {
            return .inProgress
        } else if todayProgress == goalValue {
            return .completed
        } else {
            return .exceeded
        }
    }
}
