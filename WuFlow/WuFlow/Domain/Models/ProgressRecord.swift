//
//  ProgressRecord.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 3/31/26.
//

import Foundation
import SwiftData

@Model
final class ProgressRecord {
    
    @Attribute(.unique)
    var id: UUID
    
    var value: Double
    
    var date: Date
    
    var source: TrackingType
    
    var activity: Activity?
    
    init(
        id: UUID = UUID(),
        value: Double,
        date: Date = Date(),
        source: TrackingType,
        activity: Activity
    ) {
        self.id = id
        self.value = value
        self.date = date
        self.source = source
        self.activity = activity
    }
}
