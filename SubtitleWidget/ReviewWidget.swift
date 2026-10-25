import SwiftUI
import WidgetKit

@main
struct ReviewWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ReviewWidget", provider: ReviewTimelineProvider()) { entry in
            ReviewWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Review")
        .description("Words due today and your streak.")
        .supportedFamilies([.systemSmall])
    }
}
