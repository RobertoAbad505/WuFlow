//
//  Activity+Streaks.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/17/26.
//
import Foundation

extension Activity {
    
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
    var streakMessage: String {
        switch self.currentStreak {
        case 0:
            return "Start your streak today"
        case 1...2:
            return "You're getting started"
        case 3...6:
            return "You're building consistency"
        default:
            return "You're on fire 🔥"
        }
    }
}
