//
//  DecreaseActivitySummary.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/11/26.
//
import Foundation

struct DecreaseActivitySummary: Sendable {
    let awarenessDuration: TimeInterval
    let incidentCount: Int
    let currentIncidentFreeDuration: TimeInterval
    let longestIncidentFreeDuration: TimeInterval
    let averageIncidentInterval: TimeInterval?
}
