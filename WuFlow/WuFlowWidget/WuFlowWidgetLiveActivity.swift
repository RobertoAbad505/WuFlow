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
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PlaceSessionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "circle.dotted")
                        .symbolEffect(.rotate)
                    Text(context.attributes.activityName.removingEmojis)
                        .font(.headline)
                }
                Text("📍\(context.attributes.placeName.removingEmojis)")
                .foregroundStyle(.secondary)
                Text(context.state.startedAt,
                     style: .timer)
                    .font(.title)
                    .monospacedDigit()
            }
            .padding()
            .activityBackgroundTint(Color.cyan.opacity(0.3))
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("🌿 WuFlow")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("💚 On live")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading) {
                        Text(context.attributes.activityName.removingEmojis)
                            .font(.title3)
                        Text("📍\(context.attributes.placeName.removingEmojis)")
                        Text(context.state.startedAt,
                             style: .timer)
                            .font(.title)
                            .monospacedDigit()
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
                Text("🏋️")
            }
        }
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
#Preview("Compact", as: .dynamicIsland(.minimal), using: PlaceSessionAttributes.preview) {
    WuFlowWidgetLiveActivity()
} contentStates: {
    .oneHour
}
extension PlaceSessionAttributes {

    static var preview: Self {
        .init(
            sessionID: UUID(),
            activityName: "Gym💪",
            placeName: "📍Iron GYM"
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
