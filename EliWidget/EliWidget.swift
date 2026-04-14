import WidgetKit
import SwiftUI
import ActivityKit

struct EliAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var progress: Double
        var promptPreview: String
    }
    var sessionId: String
}

struct EliLiveActivityView: View {
    let context: ActivityViewContext<EliAttributes>
    
    var body: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .foregroundColor(.purple)
            VStack(alignment: .leading) {
                Text("Eli").font(.headline)
                Text(context.state.promptPreview).font(.caption2).foregroundColor(.secondary)
            }
            Spacer()
            VStack {
                Text(context.state.status).font(.caption)
                if context.state.progress < 1.0 {
                    ProgressView(value: context.state.progress).progressViewStyle(.linear).frame(width: 80)
                } else {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                }
            }
        }.padding()
    }
}

struct EliWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EliAttributes.self) { context in
            EliLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack { Image(systemName: "brain"); Text("Eli") }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.status)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                    Text(context.state.promptPreview).font(.caption2)
                }
            } compactLeading: {
                Image(systemName: "brain")
            } compactTrailing: {
                if context.state.progress < 1.0 {
                    ProgressView(value: context.state.progress).progressViewStyle(.circular).frame(width:20,height:20)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }
            } minimal: {
                Image(systemName: context.state.progress >= 1.0 ? "checkmark.circle.fill" : "brain")
            }
        }
    }
}

@main
struct EliWidgetBundle: WidgetBundle {
    var body: some Widget { EliWidget() }
}
