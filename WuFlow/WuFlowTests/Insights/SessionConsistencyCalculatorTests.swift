//
//  SessionConsistencyCalculatorTests.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/8/26.
//


import XCTest
@testable import WuFlow

final class SessionConsistencyCalculatorTests: XCTestCase {
    
    private let engine = InsightEngine()

    private let calculator = SessionConsistencyCalculator()

    func testSessionsAreConsistentWhenDeviationIsSmall() {

        // Given
        let sessions = [
            makeSession(duration: 105 * 60),
            makeSession(duration: 110 * 60),
            makeSession(duration: 108 * 60),
            makeSession(duration: 112 * 60),
            makeSession(duration: 106 * 60)
        ]

        // When
        let result = calculator.consistency(from: sessions)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.medianDuration, 108 * 60)
        XCTAssertTrue(result?.isConsistent == true)
    }

    private func makeSession(
        duration: TimeInterval
    ) -> PlaceSession {
        PlaceSession(
            startedAt: .now.addingTimeInterval(-duration),
            endedAt: .now
        )
    }
    func testSessionsAreNotConsistentWhenDeviationIsLarge() {

        // Given
        let sessions = [
            makeSession(duration: 30 * 60),
            makeSession(duration: 60 * 60),
            makeSession(duration: 120 * 60),
            makeSession(duration: 180 * 60),
            makeSession(duration: 240 * 60)
        ]

        // When
        let result = calculator.consistency(from: sessions)

        // Then
        XCTAssertNotNil(result)
        XCTAssertFalse(result?.isConsistent == true)
    }
    
    func testConsistencyRequiresAtLeastThreeValidSessions() {

        // Given
        let sessions = [
            makeSession(duration: 60 * 60),
            makeSession(duration: 70 * 60)
        ]

        // When
        let result = calculator.consistency(from: sessions)

        // Then
        XCTAssertNil(result)
    }
    func testConsistencyIgnoresIncompleteSessions() {

        // Given
        let sessions = [
            makeSession(duration: 105 * 60),
            makeSession(duration: 110 * 60),
            makeSession(duration: 108 * 60),
            makeSession(duration: 0),
            makeSession(duration: 106 * 60)
        ]

        // When
        let result = calculator.consistency(from: sessions)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.medianDuration, 107 * 60)
    }
    func testSessionConsistencyInsightIsNotGeneratedForVariableSessions() {

        // Given
        let activity = Activity(
            name: "Workout",
            unitType: .count,
            goalValue: 10,
            iconName: "figure.strengthtraining.traditional"
        )

        let sessions = [
            makeSession(duration: 30 * 60),
            makeSession(duration: 60 * 60),
            makeSession(duration: 120 * 60),
            makeSession(duration: 180 * 60),
            makeSession(duration: 240 * 60)
        ]

        // When
        let insight = engine.sessionConsistencyInsight(
            for: activity,
            sessions: sessions
        )

        // Then
        XCTAssertNil(insight)
    }
}
