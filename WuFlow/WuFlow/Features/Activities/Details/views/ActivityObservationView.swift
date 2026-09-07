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
            ActivityImageView(path: observation.imagePath, icon: "circle.dotted")
                .frame(maxHeight: 200)
                .id(observation.imagePath)
            VStack {
                HStack {
                    Text(observation.emotion ?? "")
                    Spacer()
                    Text(observation.date, style: .date)
                }
                Text(observation.note)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    
    let path = try? ImageStore.shared.save(UIImage(named: "activityImg") ?? UIImage(), category: .activity)
    let activity = Activity(name: "Exercise",
                            unitType: .count,
                            goalValue: 10
                            )
    ActivityObservationView(observation: .init(note: "Today I felt better",
                                               emotion: "Sad",
                                               imagePath: path,
                                               activity: activity
                                              )
    )
}
