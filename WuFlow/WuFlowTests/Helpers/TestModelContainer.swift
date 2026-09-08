//
//  TestModelContainer.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/7/26.
//
import SwiftData
@testable import WuFlow

final class TestModelContainer {

    static func make() throws -> ModelContainer {

        let schema = Schema([
            Activity.self,
            ProgressRecord.self,
            ObservationRecord.self,
            Place.self,
            PlaceSession.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}
