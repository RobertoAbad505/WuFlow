//
//  GoalStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct GoalStepView: View {

    @Binding var draft: ActivityDraft

    @FocusState private var isFocused: Bool

    var body: some View {

        VStack(spacing: 24) {

            titleSection

            goalInput

            periodSelector

            goalPreview

            Spacer()
        }
        .padding()
        .onAppear {
            isFocused = true
        }
    }
    private var title: String {

        switch draft.measurementType {

        case .session:
            return "What's your target?"

        case .duration:
            return "How much time would you like to dedicate?"

        case .count:
            return "What's your target count?"

        case .distance:
            return "How far would you like to go?"
        }
    }
    private var subtitle: String {

        switch draft.measurementType {

        case .session:
            return "Choose how many sessions you'd like to complete."

        case .duration:
            return "Choose how many minutes you'd like to invest."

        case .count:
            return "Choose a measurable target."

        case .distance:
            return "Choose the distance you'd like to achieve."
        }
    }
    
    private var titleSection: some View {

        VStack(spacing: 8) {

            Text(title)
                .font(.title2.bold())

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    private var goalInput: some View {

        VStack(spacing: 8) {

            TextField(
                "0",
                value: $draft.goalValue,
                format: .number
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 48, weight: .bold))
            .focused($isFocused)

            Text(unitLabel)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    private var unitLabel: String {

        switch draft.measurementType {

        case .session:
            return draft.goalValue == 1
            ? "Session"
            : "Sessions"

        case .duration:
            return "Minutes"

        case .count:
            return "Count"

        case .distance:
            return "Kilometers"
        }
    }
    private var periodSelector: some View {

        VStack(alignment: .leading) {

            Text("How often?")
                .font(.headline)

            HStack {

                ForEach(
                    GoalPeriod.allCases,
                    id: \.self
                ) { period in

                    Button {

                        draft.goalPeriod = period

                    } label: {

                        Text(period.displayName)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                draft.goalPeriod == period
                                ? Color.accentColor.opacity(0.2)
                                : Color.secondary.opacity(0.1)
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 12
                                )
                            )
                    }
                }
            }
        }
    }
    private var goalPreview: some View {

        VStack(spacing: 8) {

            Text("Your Goal")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(goalSummary)
                .font(.title3.bold())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
    private var goalSummary: String {

        "\(Int(draft.goalValue)) \(unitLabel) \(draft.goalPeriod.displayName)"
    }
}
