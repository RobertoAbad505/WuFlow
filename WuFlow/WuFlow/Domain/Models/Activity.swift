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
    
    var goalValue: Double
    
    var trackingType: TrackingType
    
    var createdAt: Date
    
    var isPinned: Bool = false
    
    var motivationDescription: String?
    
    var expectedOutcomeDescription: String?
    
    var iconName: String?
    
    var imageData: Data?
    
    var type: ActivityTypes
    
    var lifeArea: LifeArea
    
    var secondaryNote: String?
    
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
        imageData: Data? = nil,
        type: ActivityTypes = .maintain,
        lifeArea: LifeArea = .leisure,
        secondaryNote: String? = nil,
        progressRecords: [ProgressRecord] = []
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
        self.imageData = imageData
        self.type = type
        self.lifeArea = lifeArea
        self.secondaryNote = secondaryNote
        self.progressRecords = progressRecords
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
    var currentStreak: Int {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: progressRecords) {
            calendar.startOfDay(for: $0.date)
        }
        
        var streak = 0
        var date = Date()
        
        // 🔥 If today is not completed, start from yesterday
        let todayTotal = grouped[calendar.startOfDay(for: date)]?
            .reduce(0) { $0 + $1.value } ?? 0
        
        if !isDayCompleted(total: todayTotal) {
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        }
        
        while true {
            let day = calendar.startOfDay(for: date)
            let total = grouped[day]?.reduce(0) { $0 + $1.value } ?? 0
            
            if isDayCompleted(total: total) {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        
        return streak
    }
    var longestStreak: Int {
        let calendar = Calendar.current
        
        let days = dailyTotals
        
        var longest = 0
        var current = 0
        var previousDay: Date?
        
        for day in days {
            
            if isDayCompleted(total: day.total) {
                
                if let prev = previousDay,
                   calendar.isDate(
                       day.date,
                       inSameDayAs: calendar.date(byAdding: .day, value: 1, to: prev)!
                   ) {
                    
                    current += 1
                } else {
                    current = 1
                }
                
                longest = max(longest, current)
                previousDay = day.date
                
            } else {
                current = 0
                previousDay = nil
            }
        }
        
        return longest
    }
    func isDayCompleted(total: Double) -> Bool {
        total >= goalValue
    }
    func isDayCompleted(for date: Date, total: Double) -> Bool {
        total >= goalValue
    }
    var dailyTotals: [(date: Date, total: Double)] {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: progressRecords) {
            calendar.startOfDay(for: $0.date)
        }
        
        return grouped
            .map { (date: $0.key, total: $0.value.reduce(0) { $0 + $1.value }) }
            .sorted { $0.date < $1.date }
    }
    var uiImage: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
    var isCompletedToday: Bool {
        todayProgress >= goalValue
    }

}
enum ActivityTypes: String, Codable, CaseIterable {
    case increase// build / do more
    case maintain// stay consistent (Wu Wei)
    case decrease// reduce / avoid
    
    var name: String {
        switch self {
            case .increase: return "🌱 Build"
            case .decrease: return "🔥 Reduce"
            case .maintain: return "🌊 Flow"
        }
    }
}
