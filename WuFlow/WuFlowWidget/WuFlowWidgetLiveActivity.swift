//
//  WuFlowWidgetLiveActivity.swift
//  WuFlowWidget
//
//  Created by Roberto Ramirez on 7/22/26.
//

import ActivityKit
import WidgetKit
import SwiftUI


struct WuFlowWidgetLiveActivity: Widget {
    
    let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PlaceSessionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Image(systemName: context.attributes.icon)
                        .font(.system(size: 30))
                    VStack(alignment: .center, spacing: 5) {
                        Text(context.attributes.activityName)
                            .font(.system(size: 15))
                        Text("📍\(context.attributes.placeName)")
                            .font(.system(size: 20))
                    }
                    Spacer()
                    Text("\(progressStatus(context))")
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
                .padding()
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Workout time")
                            .font(.footnote)
                        Text(context.state.startedAt, style: .timer)
                            .font(.title)
                            .monospacedDigit()
                    }
                    VStack(alignment: .center) {
                        Text("Started time")
                        Text(context.state.startedAt, style: .time)
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Text("Typical session")
                        Text("\(typicalSessionText(context))")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                    }
                }
                .font(.footnote)
                SessionProgressView(context: context)
            }
            .padding()
            .activityBackgroundTint(.black.opacity(0.7))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("🌿\(context.attributes.activityName.removingEmojis)")
                        .font(.title3.bold())
                        .padding(2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("📍\(context.attributes.placeName.removingEmojis)")
                        .padding(2)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: context.attributes.icon)
                                .font(.system(size: 25))
                                .symbolEffect(.rotate)
                            VStack(alignment: .leading) {
                                Text("Temps")
                                    .font(.footnote)
                                Text(context.state.startedAt, style: .timer)
                                    .font(.title3)
                                    .monospacedDigit()
                            }
                            VStack(alignment: .center) {
                                Text("Started time")
                                    .font(.footnote)
                                Text(context.state.startedAt, style: .time)
                                    .font(.body)
                                    .monospacedDigit()
                                    .foregroundColor(.secondary)
                            }
                        }
                        SessionProgressView(context: context)
                    }
                }
            } compactLeading: {
                Text("🌿 \(context.attributes.activityName.removingEmojis)")
                    .bold()
            } compactTrailing: {
                Text(
                    context.state.startedAt,
                    style: .timer
                )
                .monospacedDigit()
            } minimal: {
                Text("🌿")
            }
        }
    }
    
    private func expectedEndDate(_ context: ActivityViewContext<PlaceSessionAttributes>) -> Date? {
        guard let expectedDuration = context.attributes.expectedDuration else {
            return nil
        }

        return context.state.startedAt
            .addingTimeInterval(expectedDuration)
    }
    private func progressStatus(_ context: ActivityViewContext<PlaceSessionAttributes>) -> String {
        guard let expectedEndDate = expectedEndDate(context) else {
            return "In progress"
        }
        let now = Date()
        let start = context.state.startedAt
        let expectedDuration = expectedEndDate.timeIntervalSince(start)
        let elapsed = now.timeIntervalSince(start)

        let progress = elapsed / expectedDuration

        switch progress {
        case 0..<0.75:
            return "Keep going!💪"
        case 0.75..<1.0:
            return "Almost there!🏆"
        default:
            return "Exceeded typical time 🚀"
        }
    }
    func typicalSessionText(_ context: ActivityViewContext<PlaceSessionAttributes>) -> String {
        guard let expectedDuration = context.attributes.expectedDuration else {
            return "Typical session unavailable"
        }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated

        return formatter.string(from: expectedDuration)
            ?? "-"
    }
}


#Preview("Notification",
         as: .content,
         using: PlaceSessionAttributes.preview) {
   WuFlowWidgetLiveActivity()
} contentStates: {
    PlaceSessionAttributes.ContentState.justStarted
    PlaceSessionAttributes.ContentState.fifteenMinutes
    PlaceSessionAttributes.ContentState.oneHour
}
#Preview("Lock Screen", as: .content, using: PlaceSessionAttributes.preview) {
    WuFlowWidgetLiveActivity()
} contentStates: {
    .oneHour
}

#Preview("Expanded", as: .dynamicIsland(.expanded), using: PlaceSessionAttributes.preview) {
    WuFlowWidgetLiveActivity()
} contentStates: {
    .oneHour
}

#Preview("Compact", as: .dynamicIsland(.compact), using: PlaceSessionAttributes.preview) {
    WuFlowWidgetLiveActivity()
} contentStates: {
    .oneHour
}
#Preview("Minimal", as: .dynamicIsland(.minimal), using: PlaceSessionAttributes.preview) {
    WuFlowWidgetLiveActivity()
} contentStates: {
    .oneHour
}
extension PlaceSessionAttributes {

    static var preview: Self {
        .init(
            sessionID: UUID(),
            activityName: "Gym",
            placeName: "Iron GYM",
            icon: "circle.dotted",
            expectedDuration: 6480
        )
    }
}
extension PlaceSessionAttributes.ContentState {

    static var justStarted: Self {
        .init(
            startedAt: .now
        )
    }

    static var fifteenMinutes: Self {
        .init(
            startedAt: .now.addingTimeInterval(-15 * 60)
        )
    }

    static var oneHour: Self {
        .init(
            startedAt: .now.addingTimeInterval(-3600)
        )
    }

    static var marathon: Self {
        .init(
            startedAt: .now.addingTimeInterval(-4 * 3600)
        )
    }
}
