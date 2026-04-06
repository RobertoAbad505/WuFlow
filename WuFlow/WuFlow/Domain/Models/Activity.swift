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
