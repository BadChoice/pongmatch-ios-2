//
//  Pongmatch_widgetLiveActivity.swift
//  Pongmatch-widget
//
//  Created by Jordi Puigdellívol on 12/9/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Pongmatch_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Pongmatch_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Pongmatch_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("\(context.state.emoji) JP  2 - 1  GM")
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

extension Pongmatch_widgetAttributes {
    fileprivate static var preview: Pongmatch_widgetAttributes {
        Pongmatch_widgetAttributes(name: "World")
    }
}

extension Pongmatch_widgetAttributes.ContentState {
    fileprivate static var smiley: Pongmatch_widgetAttributes.ContentState {
        Pongmatch_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Pongmatch_widgetAttributes.ContentState {
         Pongmatch_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Pongmatch_widgetAttributes.preview) {
   Pongmatch_widgetLiveActivity()
} contentStates: {
    Pongmatch_widgetAttributes.ContentState.smiley
    Pongmatch_widgetAttributes.ContentState.starEyes
}
