//
//  DebugDataSeeder.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/14/26.
//
import Foundation
import SwiftData
import SwiftUI

struct DebugDataSeeder {
    @Environment(\.modelContext) private var modelContext
    
    func deleteAllData() {
        let activities = try? modelContext.fetch(FetchDescriptor<Activity>())
        let records = try? modelContext.fetch(FetchDescriptor<ProgressRecord>())
        
        activities?.forEach { modelContext.delete($0) }
        records?.forEach { modelContext.delete($0) }
    }
    
    static func seedSampleData(context: ModelContext) {
        let activities = try? context.fetch(FetchDescriptor<Activity>())
        activities?.forEach { context.delete($0) }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Create Activity
        let activity = Activity(
            name: "Test Activity",
            unitType: .minutes,
            goalValue: 30,
            trackingType: .manual
        )
        
        context.insert(activity)
        
        // Helper to create dates
        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: now)!
        }
        
        // Sample records
        let sampleData: [(Int, Double)] = [
            (0, 10),  // today
            (0, 5),   // today
            (1, 20),  // yesterday
            (2, 15),  // 2 days ago
            (3, 25),
            (5, 30),
            (7, 18),  // last week
            (8, 22),
            (10, 12),
            (20, 40), // last month-ish
            (25, 35)
        ]
        
        for (daysAgoValue, value) in sampleData {
            let date = daysAgo(daysAgoValue)
            
            let record = ProgressRecord(
                value: value,
                date: date,
                source: .manual,
                activity: activity
            )
            
            activity.progressRecords.append(record)
            context.insert(record)
        }
        
        do {
            try context.save()
            print("✅ Seed data created")
        } catch {
            print("❌ Error seeding data:", error)
        }
    }
}
