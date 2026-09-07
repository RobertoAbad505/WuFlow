//
//  ObservationRecord.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/6/26.
//


import Foundation
import SwiftData

@Model
final class ObservationRecord {

    @Attribute(.unique)
    var id: UUID

    var date: Date
    var note: String

    /// User-selected emotion/context indicator.
    /// Example: "😰", "😀", "😴"
    var emotion: String?

    /// Local path managed by ImageStore.
    var imagePath: String?

    var activity: Activity

    init(
        date: Date = .now,
        note: String,
        emotion: String? = nil,
        imagePath: String? = nil,
        activity: Activity
    ) {
        self.id = UUID()
        self.date = date
        self.note = note
        self.emotion = emotion
        self.imagePath = imagePath
        self.activity = activity
    }
}
