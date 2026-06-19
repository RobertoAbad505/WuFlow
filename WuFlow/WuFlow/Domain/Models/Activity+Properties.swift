//
//  Activity+Properties.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/17/26.
//


extension Activity {
    
    ///Property helpers
    var reminderType: ReminderType {
        get {
            ReminderType(rawValue: reminderTypeRawValue ?? "")
            ?? .contextual
        }
        set {
            reminderTypeRawValue = newValue.rawValue
        }
    }
    
    var reminderTone: ReminderTone {
        get {
            ReminderTone(rawValue: reminderToneRawValue ?? "")
            ?? .light
        }
        set {
            reminderToneRawValue = newValue.rawValue
        }
    }
    var reminderPreset: ReminderPreset {
        get {
            ReminderPreset(rawValue: reminderPresetRawValue ?? "")
            ?? .morning
        }
        set {
            reminderPresetRawValue = newValue.rawValue
        }
    }
    var measurement: MeasurementType {
        get {
            MeasurementType(
                rawValue: measurementRaw
            ) ?? .session
        }
        set {
            measurementRaw = newValue.rawValue
        }
    }

    var goalPeriod: GoalPeriod {
        get {
            GoalPeriod(
                rawValue: goalPeriodRaw
            ) ?? .daily
        }
        set {
            goalPeriodRaw = newValue.rawValue
        }
    }
    var lifeArea: LifeArea {
        get {
            LifeArea(
                rawValue: lifeAreaRaw ?? ""
            ) ?? .social
        }
        set {
            lifeAreaRaw = newValue.rawValue
        }
    }
    
    var type: ActivityTypes {
        get {
            ActivityTypes(
                rawValue: typeRaw ?? ""
            ) ?? .maintain
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
}