//
//  SessionConsistencyCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/8/26.
//


import Foundation

final class SessionConsistencyCalculator {

    func consistency(
        from sessions: [PlaceSession]
    ) -> SessionConsistency? {

        let durations = sessions
            .compactMap(\.duration)
            .filter { $0 > 0 }
            .sorted()

        guard durations.count >= 3 else {
            return nil
        }

        let median = calculateMedian(durations)

        let totalDeviation = durations.reduce(0) { total, duration in
            total + abs(duration - median)
        }

        let averageDeviation =
            totalDeviation / Double(durations.count)

        return SessionConsistency(
            medianDuration: median,
            averageDeviation: averageDeviation
        )
    }

    private func calculateMedian(
        _ values: [TimeInterval]
    ) -> TimeInterval {

        let middleIndex = values.count / 2

        if values.count.isMultiple(of: 2) {
            return (
                values[middleIndex - 1] +
                values[middleIndex]
            ) / 2
        }

        return values[middleIndex]
    }
}
struct SessionConsistency: Sendable {
    let medianDuration: TimeInterval
    let averageDeviation: TimeInterval

    var isConsistent: Bool {
        averageDeviation <= 10 * 60
    }
}
