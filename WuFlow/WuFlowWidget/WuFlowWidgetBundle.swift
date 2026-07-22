//
//  WuFlowWidgetBundle.swift
//  WuFlowWidget
//
//  Created by Roberto Ramirez on 7/22/26.
//

import WidgetKit
import SwiftUI

@main
struct WuFlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        WuFlowWidget()
        WuFlowWidgetControl()
        WuFlowWidgetLiveActivity()
    }
}
