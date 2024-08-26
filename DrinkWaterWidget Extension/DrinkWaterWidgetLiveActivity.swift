//
//  DrinkWaterWidgetLiveActivity.swift
//  DrinkWaterWidget
//
//  Created by Alexander Lyubimov on 21.07.2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DrinkWaterWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DrinkWaterWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DrinkWaterWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DrinkWaterWidgetAttributes {
    fileprivate static var preview: DrinkWaterWidgetAttributes {
        DrinkWaterWidgetAttributes(name: "World")
    }
}

extension DrinkWaterWidgetAttributes.ContentState {
    fileprivate static var smiley: DrinkWaterWidgetAttributes.ContentState {
        DrinkWaterWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DrinkWaterWidgetAttributes.ContentState {
         DrinkWaterWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DrinkWaterWidgetAttributes.preview) {
   DrinkWaterWidgetLiveActivity()
} contentStates: {
    DrinkWaterWidgetAttributes.ContentState.smiley
    DrinkWaterWidgetAttributes.ContentState.starEyes
}
