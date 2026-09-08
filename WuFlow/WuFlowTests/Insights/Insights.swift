//
//  Insights.swift
//  WuFlowTests
//
//  Created by Roberto Ramirez on 9/7/26.
//
import Foundation
import Testing
import XCTest
@testable import WuFlow

final class InsightEngineTests: XCTestCase {

    private let engine = InsightEngine()

    func testTypicalSessionInsightIsGenerated() throws {

        // Given
        let activity = Activity(
            name: "Workout",
            unitType: .sessions,
            goalValue: 10,
            iconName: "figure.strengthtraining.traditional"
        )

        let sessions = [
            makeSession(duration: 52 * 60),
            makeSession(duration: 61 * 60),
            makeSession(duration: 58 * 60),
            makeSession(duration: 67 * 60),
            makeSession(duration: 55 * 60)
        ]

        // When
        let insight = engine.typicalSessionInsight(
            for: activity,
            sessions: sessions
        )

        // Then
        XCTAssertNotNil(insight)
        XCTAssertEqual(insight?.title, "Your typical session")
        XCTAssertEqual(
            insight?.message,
            "You usually spend about 58m here."
        )
    }
    func testTypicalSessionInsightRequiresEnoughSessions() throws {

        // Given
        let activity = Activity(
            name: "Workout",
            unitType: .sessions,
            goalValue: 10,
            iconName: "figure.strengthtraining.traditional"
        )

        let sessions = [
            makeSession(duration: 52 * 60),
            makeSession(duration: 61 * 60)
        ]

        // When
        let insight = engine.typicalSessionInsight(
            for: activity,
            sessions: sessions
        )

        // Then
        XCTAssertNil(insight)
    }
    private func makeSession(duration: TimeInterval) -> PlaceSession {
        let session = PlaceSession(
            startedAt: .now.addingTimeInterval(-duration),
            endedAt: .now
        )

        return session
    }
}
