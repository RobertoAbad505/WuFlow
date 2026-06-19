//
//  Activity+Progress.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/17/26.
//

import Foundation

extension Activity {
    var isCompletedToday: Bool {
        currentPeriodProgress >= goalValue
    }
    var todayProgress: Double {
        let calendar = Calendar.current

        return progressRecords
            .filter {
                calendar.isDateInToday($0.date)
            }
            .reduce(0) { $0 + $1.value }
    }
    var status: ActivityStatus {
        if currentPeriodProgress == 0 {
            return .notStarted
        } else if currentPeriodProgress < goalValue {
            return .inProgress
        } else if currentPeriodProgress == goalValue {
            return .completed
        } else {
            return .exceeded
        }
    }
    var progressRatio: Double {
        guard goalValue > 0 else {
            return 0
        }
        return min(currentPeriodProgress / goalValue, 1.0)
    }
    var progressPercentage: Int {
        Int(progressRatio * 100)
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
    func recordsForCurrentPeriod() -> [ProgressRecord] {
        
        let calendar = Calendar.current
        
        switch goalPeriod {
            
        case .daily:
            
            return progressRecords.filter {
                calendar.isDateInToday($0.date)
            }
            
        case .weekly:
            
            return progressRecords.filter {
                calendar.isDate(
                    $0.date,
                    equalTo: Date(),
                    toGranularity: .weekOfYear
                )
            }
            
        case .monthly:
            
            return progressRecords.filter {
                calendar.isDate(
                    $0.date,
                    equalTo: Date(),
                    toGranularity: .month
                )
            }
        }
    }
    var currentPeriodProgress: Double {
        recordsForCurrentPeriod()
            .reduce(0) { $0 + $1.value }
    }
    var goalDescription: String {
        "\(Int(goalValue)) \(measurement.displayName) \(goalPeriod.displayName)"
    }
    var progressDescription: String {
        "\(Int(currentPeriodProgress)) / \(Int(goalValue)) \(measurement.displayName)"
    }
    var periodDescription: String {
        switch goalPeriod {
        case .daily:
            return "\(progressPercentage)% of today's goal"
        case .weekly:
            return "\(progressPercentage)% of this week's goal"
        case .monthly:
            return "\(progressPercentage)% of this month's goal"
        }
    }
    var goalStatus: GoalStatus {
        if currentPeriodProgress >= self.goalValue {
            return currentPeriodProgress > self.goalValue ? .exceeded : .completed
        } else {
            return .inProgress
        }
    }
    var feedbackMessage: String {
        switch self.goalStatus {
        case .inProgress:
            if self.progressRatio == 0 {
                return "Start small today 🌱"
            } else if self.progressRatio < 0.5 {
                return "You're building momentum"
            } else {
                return "You're almost there"
            }
        case .completed:
            return "Goal reached 🎉"
        case .exceeded:
            return "You exceeded your goal 🚀"
        }
    }
}

