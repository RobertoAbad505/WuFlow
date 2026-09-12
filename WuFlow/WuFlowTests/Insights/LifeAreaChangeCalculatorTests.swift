//
//  LifeAreaChangeCalculatorTests.swift
//  WuFlowTests
//
//  Created by Roberto Ramirez on 9/11/26.
//
@testable import WuFlow
import XCTest

final class LifeAreaChangeCalculatorTests: XCTestCase {
    
    private let calculator = LifeAreaTrendCalculator()
    
    func testCalculatesLifeAreaChange() {

        // Given
        let previous = [
            makeAttention(
                lifeArea: .health,
                progressCount: 45,
                percentage: 0.45,
                total: 100
            ),
            makeAttention(
                lifeArea: .growth,
                progressCount: 25,
                percentage: 0.25,
                total: 100
            )
        ]

        let current = [
            makeAttention(
                lifeArea: .health,
                progressCount: 30,
                percentage: 0.30,
                total: 100
            ),
            makeAttention(
                lifeArea: .growth,
                progressCount: 40,
                percentage: 0.40,
                total: 100
            )
        ]

        // When
        let result = calculator.calculate(
            previous: previous,
            current: current
        )

        // Then
        XCTAssertEqual(result.count, 2)

        let growth = result.first {
            $0.lifeArea == .growth
        }

        XCTAssertEqual(
            growth?.percentagePointChange ?? 0.0,
            0.15,
            accuracy: 0.0001
        )
    }
    
    func testLargestIncreaseComesFirst() {

        let previous = [
            makeAttention(
                lifeArea: .health,
                progressCount: 50,
                percentage: 0.50,
                total: 100
            ),
            makeAttention(
                lifeArea: .growth,
                progressCount: 20,
                percentage: 0.20,
                total: 100
            )
        ]

        let current = [
            makeAttention(
                lifeArea: .health,
                progressCount: 40,
                percentage: 0.40,
                total: 100
            ),
            makeAttention(
                lifeArea: .growth,
                progressCount: 35,
                percentage: 0.35,
                total: 100
            )
        ]

        let result = calculator.calculate(
            previous: previous,
            current: current
        )

        XCTAssertEqual(
            result.first?.lifeArea,
            .growth
        )
    }
    
    func testNewLifeAreaHasPositiveChange() {

        let previous = [
            makeAttention(
                lifeArea: .health,
                progressCount: 10,
                percentage: 1.0,
                total: 10
            )
        ]

        let current = [
            makeAttention(
                lifeArea: .health,
                progressCount: 7,
                percentage: 0.70,
                total: 10
            ),
            makeAttention(
                lifeArea: .growth,
                progressCount: 3,
                percentage: 0.30,
                total: 10
            )
        ]

        let result = calculator.calculate(
            previous: previous,
            current: current
        )

        let growth = result.first {
            $0.lifeArea == .growth
        }

        XCTAssertEqual(
            growth?.percentagePointChange ?? 0.0,
            0.30,
            accuracy: 0.0001
        )
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
