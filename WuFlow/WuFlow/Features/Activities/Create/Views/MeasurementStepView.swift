//
//  MeasurementStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/13/26.
//

import SwiftUI

struct MeasurementStepView: View {
    
    @Binding var draft: ActivityDraft
    
    var body: some View {
        VStack(spacing: 24) {

            VStack {
                Text("How would you like to track progress?")
                    .font(.title2)
                    .multilineTextAlignment(.center)

                Text("Choose the type of measurement that best fits this activity.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(20)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))

            measurementOptions

            Spacer()
        }
        .padding()
    }
    
    private var measurementOptions: some View {

        VStack(spacing: 16) {

            ForEach(MeasurementType.allCases, id: \.self) { type in

                MeasurementCard(type: type, isSelected: $draft.measurementTypeRaw.wrappedValue == type.rawValue) {
                    draft.measurement = type
                }
            }
        }
    }
}
struct MeasurementCard: View {

    let type: MeasurementType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack(spacing: 16) {

                Image(systemName: type.icon)

                VStack(alignment: .leading) {

                    Text(type.title)

                    Text(type.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding()
        }
        .foregroundStyle(isSelected ? Color.secondary: .black)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 26))
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(isSelected ? .green.opacity(0.75) : .clear)
        )
    }
}
extension MeasurementType {

    var title: String {

        switch self {

        case .session:
            return "Sessions"

        case .duration:
            return "Minutes"

        case .count:
            return "Count"

        case .distance:
            return "Distance"
        }
    }

    var description: String {

        switch self {

        case .session:
            return "Gym, reading sessions, guitar practice"

        case .duration:
            return "Meditation, studying, focused work"

        case .count:
            return "Steps, push ups, pages read"

        case .distance:
            return "Running, walking, cycling"
        }
    }

    var icon: String {

        switch self {

        case .session:
            return "checkmark.circle"

        case .duration:
            return "clock"

        case .count:
            return "number"

        case .distance:
            return "figure.walk"
        }
    }
}

#Preview {
    MeasurementStepView(draft: .constant(.init()))
}
