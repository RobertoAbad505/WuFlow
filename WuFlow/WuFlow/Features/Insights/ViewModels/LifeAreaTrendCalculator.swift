//
//  LifeAreaTrendCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/11/26.
//
import Foundation

final class LifeAreaTrendCalculator {

    func calculate(
        previous: [LifeAreaAttention],
        current: [LifeAreaAttention]
    ) -> [LifeAreaChange] {

        let previousByArea = Dictionary(
            uniqueKeysWithValues: previous.map {
                ($0.lifeArea, $0)
            }
        )

        let currentByArea = Dictionary(
            uniqueKeysWithValues: current.map {
                ($0.lifeArea, $0)
            }
        )

        let areas = Set(previousByArea.keys)
            .union(Set(currentByArea.keys))

        return areas.map { area in
            let previousPercentage =
                previousByArea[area]?.percentage ?? 0

            let currentPercentage =
                currentByArea[area]?.percentage ?? 0

            return LifeAreaChange(
                id: area,
                lifeArea: area,
                previousPercentage: previousPercentage,
                currentPercentage: currentPercentage
            )
        }
        .sorted {
            $0.percentagePointChange >
            $1.percentagePointChange
        }
    }
}
