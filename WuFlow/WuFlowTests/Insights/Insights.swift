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
    func testInsightsReturnsAvailableInsights() {

        // Given
        let activity = Activity(
            name: "Workout",
            unitType: .sessions,
            goalValue: 10,
            iconName: "figure.strengthtraining.traditional"
        )

        let sessions = [
            makeSession(duration: 105 * 60),
            makeSession(duration: 110 * 60),
            makeSession(duration: 108 * 60),
            makeSession(duration: 112 * 60),
            makeSession(duration: 106 * 60)
        ]

        // When
        let insights = engine.insights(
            for: activity,
            sessions: sessions
        )

        // Then
        XCTAssertEqual(insights.count, 2)
    }
    func testInsightsReturnsNoInsightsWithInsufficientData() {

        // Given
        let activity = Activity(
            name: "Workout",
            unitType: .sessions,
            goalValue: 10,
            iconName: "figure.strengthtraining.traditional"
        )

        let sessions = [
            makeSession(duration: 105 * 60),
            makeSession(duration: 110 * 60)
        ]

        // When
        let insights = engine.insights(
            for: activity,
            sessions: sessions
        )

        // Then
        XCTAssertTrue(insights.isEmpty)
    }
    func testLifeAreaAttentionInsightIsGenerated() {

        // Given
        let healthActivity = makeActivity(
            name: "Workout",
            lifeArea: .health
        )

        let growthActivity = makeActivity(
            name: "Reading",
            lifeArea: .growth
        )

        let records = [
            makeProgressRecord(activity: healthActivity),
            makeProgressRecord(activity: healthActivity),
            makeProgressRecord(activity: healthActivity),
            makeProgressRecord(activity: healthActivity),

            makeProgressRecord(activity: growthActivity),
            makeProgressRecord(activity: growthActivity)
        ]

        // When
        let insight = engine.lifeAreaAttentionInsight(
            from: records,
            since: .distantPast
        )

        // Then
        XCTAssertNotNil(insight)

        XCTAssertEqual(
            insight?.title,
            "Your attention is mostly on Health"
        )

        XCTAssertEqual(
            insight?.message,
            "67% of your recorded progress this period belongs to Health."
        )
    }
    func testLifeAreaAttentionInsightReturnsNilWithoutRecords() {

        let insight = engine.lifeAreaAttentionInsight(
            from: [],
            since: .distantPast
        )

        XCTAssertNil(insight)
    }
    private func makeSession(duration: TimeInterval) -> PlaceSession {
        let session = PlaceSession(
            startedAt: .now.addingTimeInterval(-duration),
            endedAt: .now
        )

        return session
    }
    private func makeProgressRecord(
        activity: Activity,
        date: Date = .now
    ) -> ProgressRecord {

        ProgressRecord(
            value: 1,
            date: date,
            source: .manual,
            activity: activity
        )
    }
    
    private func makeActivity(
        name: String,
        lifeArea: LifeArea
    ) -> Activity {

        let activity = Activity(
            name: name,
            unitType: .count,
            goalValue: 10
        )

        activity.lifeArea = lifeArea

        return activity
    }
}
