//
//  LifeAreaChange.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/11/26.
//
import Foundation

struct LifeAreaChange: Identifiable, Sendable {

    let id: LifeArea
    let lifeArea: LifeArea

    let previousPercentage: Double
    let currentPercentage: Double

    var percentagePointChange: Double {
        currentPercentage - previousPercentage
    }
}
