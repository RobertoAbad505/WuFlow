//
//  LifeAreaAttentionCalculatorTests.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/8/26.
//


import XCTest
@testable import WuFlow

final class LifeAreaAttentionCalculatorTests: XCTestCase {

    private let calculator = LifeAreaAttentionCalculator()

    func testCalculatesAttentionByLifeArea() {

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

            makeProgressRecord(activity: growthActivity),
            makeProgressRecord(activity: growthActivity)
        ]

        // When
        let result = calculator.calculate(
            from: records
        )

        // Then
        XCTAssertEqual(result.count, 2)

        XCTAssertEqual(result[0].lifeArea, .health)
        XCTAssertEqual(result[0].progressCount, 3)

        XCTAssertEqual(result[1].lifeArea, .growth)
        XCTAssertEqual(result[1].progressCount, 2)
    }
    
    func testCalculatesPercentageByLifeArea() {

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
        let result = calculator.calculate(from: records)

        // Then
        XCTAssertEqual(
            result[0].percentage,
            4.0 / 6.0,
            accuracy: 0.0001
        )

        XCTAssertEqual(
            result[1].percentage,
            2.0 / 6.0,
            accuracy: 0.0001
        )
    }
    
    func testCalculatesAttentionFromProvidedRecords() {

        let healthActivity = makeActivity(
            name: "Workout",
            lifeArea: .health
        )

        let records = [
            makeProgressRecord(activity: healthActivity),
            makeProgressRecord(activity: healthActivity)
        ]

        let result = calculator.calculate(from: records)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].progressCount, 2)
    }
    
    private func makeAttention(
        lifeArea: LifeArea,
        progressCount: Int,
        percentage: Double,
        total: Int
    ) -> LifeAreaAttention {

        LifeAreaAttention(
            lifeArea: lifeArea,
            progressCount: progressCount,
            percentage: percentage,
            totalProgressCount: total
        )
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
