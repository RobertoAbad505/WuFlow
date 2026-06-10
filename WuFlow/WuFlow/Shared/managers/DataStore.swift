//
//  DataStore.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/8/26.
//


import SwiftData

final class DataStore {

    static let shared = DataStore()

    let container: ModelContainer

    private init() {

        let schema = Schema([
            Activity.self,
            ProgressRecord.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed creating ModelContainer: \(error)")
        }
    }
}