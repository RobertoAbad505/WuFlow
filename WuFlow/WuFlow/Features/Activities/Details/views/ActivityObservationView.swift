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
        VStack(alignment: .center, spacing: 0) {
            if hasImage {
                imageSection
            }
            VStack(spacing: 10) {
                HStack {
                    VStack {
                        Text("I felt:")
                            .font(.system(size: 8))
                        Text("\(observation.emotion ?? "")")
                            .font(.system(size: 15))
                    }
                    Spacer()
                    Text(observation.date, style: .date)
                        .font(.system(size: 10))
                }
                Text(observation.note)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                    Text("This was an incident ")
                }
                .foregroundStyle(.secondary)
                .font(.system(size: 11))
                .font(.system(.footnote, design: .monospaced, weight: .semibold))
            }
            .padding(10)
            .background(.thinMaterial)
            .background(hasImage ? .clear:.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.5),
                radius: 5,
                x: 4,
                y: 4
        )
    }
    
    var imageSection: some View {
        ZStack {
            ActivityImageView(path: observation.imagePath, icon: observation.activity.iconName)
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 250)
                .id(observation.imagePath)
        }
        .padding(5)
        .background(hasImage ? .clear:.white.opacity(0.4))
    }
    var hasImage: Bool {
        return !(observation.imagePath == nil || (observation.imagePath?.isEmpty ?? true))
    }
}

#Preview {
    
    let path = try? ImageStore.shared.save(UIImage(named: "activityImg") ?? UIImage(), category: .activity)
    let activity = Activity(name: "Exercise",
                            unitType: .count,
                            goalValue: 10
                            )
    ZStack {
        Color.white.ignoresSafeArea()
        VStack(spacing: 50) {
            ActivityObservationView(observation: .init(note: "Today I felt better",
                                                       emotion: "🫠",
                                                       imagePath: path,
                                                       activity: activity,
                                                       kind: .incident
                                                      )
            )
            ActivityObservationView(observation: .init(note: "Today I felt better",
                                                       emotion: "Sad",
                                                       imagePath: nil,
                                                       activity: activity,
                                                       kind: .note
                                                      )
            )
            ActivityObservationView(observation: .init(note: "Today I felt better",
                                                       emotion: "Sad",
                                                       imagePath: nil,
                                                       activity: activity,
                                                       kind: .incident
                                                      )
            )
        }
        .padding()
    }
}
