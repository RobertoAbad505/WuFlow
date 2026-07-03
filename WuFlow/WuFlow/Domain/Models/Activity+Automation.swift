//
//  Activity+Automation.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/2/26.
//

extension Activity {
    var isAutomated: Bool {
        trackingType != .manual
    }
    var allowsManualProgress: Bool {
        !isAutomated
    }
}
