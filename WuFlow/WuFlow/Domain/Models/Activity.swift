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
    
    var createdAt: Date
    
    var isPinned: Bool = false
    
    var pinPriority: Int = 0
    
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
    
    var trackingTypeRaw: String = TrackingType.manual.rawValue
    
    var measurementRaw: String = MeasurementType.session.rawValue
    
    var goalPeriodRaw: String = GoalPeriod.daily.rawValue
    
    var defaultIncrement: Double = 1
    
    var latitude: Double?
    
    var longitude: Double?
    
    var radius: Double = 100
    
    // Relationship
    @Relationship(deleteRule: .cascade)
    var progressRecords: [ProgressRecord] = []
//    var automation: AutomationConfiguration?
    
    init(
        id: UUID = UUID(),
        name: String,
        unitType: UnitType,
        goalValue: Double,
        trackingType: TrackingType = .manual,
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
        measurement: MeasurementType = .session,
        isPinned: Bool? = false,
//        automation: AutomationConfiguration? = nil
    ) {
        self.id = id
        self.name = name
        self.unitType = unitType
        self.goalValue = goalValue

        self.trackingTypeRaw = trackingType.rawValue

        self.createdAt = createdAt
        self.iconName = iconName
        self.imagePath = imagePath

        self.typeRaw = type.rawValue
        self.lifeAreaRaw = lifeArea.rawValue

        self.secondaryNote = secondaryNote
        self.progressRecords = progressRecords

        self.remindersEnabled = remindersEnabled
        self.reminderTypeRawValue = reminderType.rawValue

        self.goalPeriodRaw = goalPeriod.rawValue
        self.measurementRaw = measurement.rawValue

        self.isPinned = isPinned ?? false
//        self.automation = automation
    }
}

