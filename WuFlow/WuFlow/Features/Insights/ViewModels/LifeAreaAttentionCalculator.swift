//
//  LifeAreaAttentionCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/8/26.
//

import Foundation

final class LifeAreaAttentionCalculator {

    func calculate(
        from records: [ProgressRecord]
    ) -> [LifeAreaAttention] {

        guard !records.isEmpty else {
            return []
        }

        var counts: [LifeArea: Int] = [:]

        for record in records {

            let lifeArea = record.activity.lifeArea

            guard lifeArea != .undefined else {
                continue
            }

            counts[lifeArea, default: 0] += 1
        }

        let total = counts.values.reduce(0, +)

        guard total > 0 else {
            return []
        }

        return counts.map { lifeArea, count in

            let percentage =
                Double(count) / Double(total)

            return LifeAreaAttention(
                lifeArea: lifeArea,
                progressCount: count,
                percentage: percentage,
                totalProgressCount: total
            )
        }
        .sorted {
            $0.progressCount > $1.progressCount
        }
    }
}
