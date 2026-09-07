//
//  ActivityObservationView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/6/26.
//

import SwiftUI

struct ActivityObservationView: View {
    
    let observation: ObservationRecord
    
    var body: some View {
        VStack {
            Text(observation.note)
            Text(observation.emotion ?? "")
        }
    }
}

#Preview {
    ActivityObservationView(observation: .init(note: "Example"))
}
