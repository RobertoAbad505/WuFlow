//
//  Activity.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 3/31/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Activity {
    
    @Attribute(.unique)
    var id: UUID
    
    var name: String
    
    var unitType: UnitType
    
    var goalValue: Double = 1
    
    var trackingType: TrackingType
    
    var createdAt: Date
    
    var isPinned: Bool = false
    
    var motivationDescription: String?
    
    var expectedOutcomeDescription: String?
    
    var iconName: String?
    
    var imagePath: String?
    
    var typeRaw: String?
    
    var lifeAreaRaw: String?
    
    var secondaryNote: String?
    
    var remindersEnabled: Bool = false
    
    var reminderTypeRawValue: String?
    
    var reminderPresetRawValue: String?
    
    var reminderTime: Date?
    
    var reminderToneRawValue: String?
    
    var measurementRaw: String = MeasurementType.session.rawValue
    
    var goalPeriodRaw: String = GoalPeriod.daily.rawValue
    
    var defaultIncrement: Double = 1
    
    // Relationship
    @Relationship(deleteRule: .cascade)
    var progressRecords: [ProgressRecord] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        unitType: UnitType,
        goalValue: Double,
        trackingType: TrackingType,
        createdAt: Date = Date(),
        iconName: String = "circle",
        motivationDescription: String? = nil,
        expectedOutcomeDescription: String? = nil,
        imagePath: String? = nil,
        type: ActivityTypes = .maintain,
        lifeArea: LifeArea = .leisure,
        secondaryNote: String? = nil,
        progressRecords: [ProgressRecord] = [],
        remindersEnabled: Bool = false,
        reminderType: ReminderType = .scheduled,
        goalPeriod: GoalPeriod = .daily,
        measurement: MeasurementType = .session
    ) {
        self.id = id
        self.name = name
        self.unitType = unitType
        self.goalValue = goalValue
        self.trackingType = trackingType
        self.createdAt = createdAt
        self.motivationDescription = motivationDescription
        self.expectedOutcomeDescription = expectedOutcomeDescription
        self.iconName = iconName
        self.imagePath = imagePath
        self.type = type
        self.lifeArea = lifeArea
        self.secondaryNote = secondaryNote
        self.progressRecords = progressRecords
        self.remindersEnabled = remindersEnabled
        self.reminderType = reminderType
        self.goalPeriod = goalPeriod
        self.measurement = measurement
    }
}

