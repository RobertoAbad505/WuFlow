//
//  LifeAreaAttention.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/8/26.
//


import Foundation

struct LifeAreaAttention: Identifiable, Sendable {

    let id: LifeArea
    let lifeArea: LifeArea
    let progressCount: Int
    let percentage: Double
    let totalProgressCount: Int

    init(
        lifeArea: LifeArea,
        progressCount: Int,
        percentage: Double,
        totalProgressCount: Int
    ) {
        self.id = lifeArea
        self.lifeArea = lifeArea
        self.progressCount = progressCount
        self.percentage = percentage
        self.totalProgressCount = totalProgressCount
    }
}
