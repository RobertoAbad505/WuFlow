//
//  TrackingStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/23/26.
//
import SwiftUI

struct TrackingStepView: View {

    @Binding var draft: ActivityDraft

    var body: some View {

        VStack(spacing: 28) {

            Text("How should WuFlow track this activity?")
                .font(.title2)
                .multilineTextAlignment(.center)

            Text(
                "Choose how progress will be recorded."
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            VStack(spacing: 12) {

                trackingCard(
                    type: .manual,
                    icon: "square.and.pencil",
                    title: "Manual",
                    subtitle: "You record progress yourself."
                )

                trackingCard(
                    type: .healthSteps,
                    icon: "figure.walk",
                    title: "Step Count",
                    subtitle: "Progress comes from HealthKit steps."
                )

                trackingCard(
                    type: .healthWorkout,
                    icon: "figure.run",
                    title: "Workout",
                    subtitle: "Progress comes from HealthKit workouts."
                )

                trackingCard(
                    type: .location,
                    icon: "location",
                    title: "Location",
                    subtitle: "Progress is detected when visiting a place."
                )
            }
        }
        .padding()
    }
}
extension TrackingStepView {

    func trackingCard(
        type: TrackingType,
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {

        Button {

            draft.trackingType = type

        } label: {

            HStack(spacing: 16) {

                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 40)

                VStack(alignment: .leading) {

                    Text(title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if draft.trackingType == type {

                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        draft.trackingType == type
                        ? Color.green.opacity(0.15)
                        : Color.white.opacity(0.6)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
