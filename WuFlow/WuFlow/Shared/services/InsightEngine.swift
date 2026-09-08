//
//  InsightEngine.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/7/26.
//
import Foundation

final class InsightEngine {

    private let sessionDurationCalculator: SessionDurationCalculator

    init(
        sessionDurationCalculator: SessionDurationCalculator = SessionDurationCalculator()
    ) {
        self.sessionDurationCalculator = sessionDurationCalculator
    }

    func typicalSessionInsight(
        for activity: Activity,
        sessions: [PlaceSession]
    ) -> Insight? {

        guard let expectedDuration =
                sessionDurationCalculator.expectedDuration(
                    from: sessions
                )
        else {
            return nil
        }

        let durationText = formatDuration(expectedDuration)

        return Insight(
            title: "Your typical session",
            message: "You usually spend about \(durationText) here."
        )
    }

    private func formatDuration(
        _ duration: TimeInterval
    ) -> String {

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated

        return formatter.string(from: duration) ?? "-"
    }
}
