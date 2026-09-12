//
//  InsightEngine.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/7/26.
//
import Foundation

final class InsightEngine {

    private let sessionConsistencyCalculator: SessionConsistencyCalculator
    private let sessionDurationCalculator: SessionDurationCalculator
    private let lifeAreaAttentionCalculator: LifeAreaAttentionCalculator
    private let lifeAreaTrendCalculator: LifeAreaTrendCalculator
    private let periodCalculator = PeriodCalculator()
    
    //periods
    private let insightPeriod: ComparisonPeriod = .days(30)

    init(
        sessionDurationCalculator: SessionDurationCalculator = SessionDurationCalculator(),
        sessionConsistencyCalculator: SessionConsistencyCalculator = SessionConsistencyCalculator(),
        lifeAreaAttentionCalculator: LifeAreaAttentionCalculator = LifeAreaAttentionCalculator(),
        lifeAreaTrendCalculator: LifeAreaTrendCalculator = LifeAreaTrendCalculator()
    ) {
        self.sessionDurationCalculator = sessionDurationCalculator
        self.sessionConsistencyCalculator = sessionConsistencyCalculator
        self.lifeAreaAttentionCalculator = lifeAreaAttentionCalculator
        self.lifeAreaTrendCalculator = lifeAreaTrendCalculator
    }
    
    func insights(
        for activity: Activity,
        sessions: [PlaceSession]
    ) -> [Insight] {

        var insights: [Insight] = []

        if let insight = typicalSessionInsight(
            for: activity,
            sessions: sessions
        ) {
            insights.append(insight)
        }

        if let insight = sessionConsistencyInsight(
            for: activity,
            sessions: sessions
        ) {
            insights.append(insight)
        }

        return insights
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
            print("💡🚫[INSIGHTS] No 'typicalSessionInsight' insight data for \(activity.name)")
            return nil
        }

        let durationText = formatDuration(expectedDuration)

        return Insight(
            title: "Your typical session",
            message: "You usually spend about \(durationText) here."
        )
    }
    
    func sessionConsistencyInsight(
        for activity: Activity,
        sessions: [PlaceSession]
    ) -> Insight? {

        guard let consistency =
                sessionConsistencyCalculator.consistency(from: sessions)
        else {
            print("💡🚫[INSIGHTS] No 'sessionConsistency' insight - No relevant data for \(activity.name)")
            return nil
        }
        guard consistency.isConsistent else {
            print("💡🚫[INSIGHTS] No 'sessionConsistency' insight - Not consistent data for \(activity.name)")
            return nil
        }

        return Insight(
            title: "You're pretty consistent",
            message: "Most of your sessions stay close to your typical duration."
        )
    }
    //General Inights - Home Scren insights
    func generalInsights(
        from records: [ProgressRecord],
        endingAt date: Date = .now
    ) -> [Insight] {

        var insights: [Insight] = []

        let periods = periodCalculator.comparison(
            period: .days(30),
            endingAt: date
        )

        // Current attention
        if let attentionInsight = lifeAreaAttentionInsight(
            from: records,
            since: periods.current.start
        ) {
            insights.append(attentionInsight)
        }

        // Life Area trend
        if let trendInsight = lifeAreaTrendInsight(
            from: records,
            period: .days(30),
            endingAt: date
        ) {
            insights.append(trendInsight)
        }

        return insights
    }
    
    func lifeAreaAttentionInsight(
        from records: [ProgressRecord],
        since startDate: Date
    ) -> Insight? {

        let attention = lifeAreaAttentionCalculator.calculate(
            from: records.filter {
                $0.date >= startDate
            }
        )

        guard let topArea = attention.first else {
            return nil
        }

        let percentage = Int(
            (topArea.percentage * 100).rounded()
        )

        return Insight(
            title: "Your attention is mostly on \(topArea.lifeArea.title)",
            message: "\(percentage)% of your recorded progress this period belongs to \(topArea.lifeArea.title)."
        )
    }
    func lifeAreaTrendInsight(
        from records: [ProgressRecord],
        period: ComparisonPeriod = .days(30),
        endingAt date: Date = .now
    ) -> Insight? {

        let periods = periodCalculator.comparison(
            period: period,
            endingAt: date
        )

        let previousRecords = records.filter {
            periods.previous.contains($0.date)
        }

        let currentRecords = records.filter {
            periods.current.contains($0.date)
        }

        // Avoid generating insights from very small samples.
        guard previousRecords.count >= 5,
              currentRecords.count >= 5
        else {
            return nil
        }

        let previousAttention =
            lifeAreaAttentionCalculator.calculate(
                from: previousRecords
            )

        let currentAttention =
            lifeAreaAttentionCalculator.calculate(
                from: currentRecords
            )

        let changes = lifeAreaTrendCalculator.calculate(
            previous: previousAttention,
            current: currentAttention
        )

        guard let largestIncrease = changes.first,
              largestIncrease.percentagePointChange > 0
        else {
            return nil
        }

        let previousPercentage = Int(
            (largestIncrease.previousPercentage * 100).rounded()
        )

        let currentPercentage = Int(
            (largestIncrease.currentPercentage * 100).rounded()
        )

        return Insight(
            title: "\(largestIncrease.lifeArea.title) is receiving more of your attention",
            message: "Your recorded progress in \(largestIncrease.lifeArea.title) increased from \(previousPercentage)% to \(currentPercentage)% compared with the previous period."
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
