//
//  ProgressSummary.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 8/9/26.
//


struct ProgressSummary {

    let value: Double

    let goal: Double

    let ratio: Double

    let percentage: Int
    
    let remaining: Double

    let status: ActivityStatus

    let records: [ProgressRecord]

    let completed: Bool   

}
extension ProgressSummary {

    func description(_ measurement: MeasurementType) -> String {
        "\(Int(value)) / \(Int(goal)) \(measurement.displayName)"
    }
}
