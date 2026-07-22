//
//  PlaceSessionAttributes.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/22/26.
//
import Foundation
import ActivityKit

struct PlaceSessionAttributes: ActivityAttributes {

    struct ContentState: Codable, Hashable {
        var startedAt: Date
    }
    let sessionID: UUID
    let activityName: String
    let placeName: String
}
