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
    var kindRaw: String?

    init(
        date: Date = .now,
        note: String,
        emotion: String? = nil,
        imagePath: String? = nil,
        activity: Activity,
        kind: ObservationKind = .note
    ) {
        self.id = UUID()
        self.date = date
        self.note = note
        self.emotion = emotion
        self.imagePath = imagePath
        self.activity = activity
        self.kindRaw = kind.rawValue
    }
}
extension ObservationRecord {
    var kind: ObservationKind {
        get {
            guard let kindRaw else {
                return .note
            }

            return ObservationKind(rawValue: kindRaw) ?? .note
        }
        set {
            kindRaw = newValue.rawValue
        }
    }
}
enum ObservationKind: String, Codable {
    case note
    case incident
}
