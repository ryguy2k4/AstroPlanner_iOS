//
//  DeepSkyCatalogWidget.swift
//  DeepSkyCatalogWidget
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import WidgetKit
import SwiftUI

struct DeepSkyCatalogWidget: Widget {
    let kind: String = "DeepSkyCatalogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TopThreeWidgetView(entry: entry)
        }
        .configurationDisplayName("Top Three Targets")
        .description("This widget displays the top three targets for today")
        .supportedFamilies([.systemMedium])
    }
}

struct DeepSkyCatalogWidget_Previews: PreviewProvider {
    static var previews: some View {
        let topThree = [DeepSkyTargetList.whitelistedTargets[0], DeepSkyTargetList.whitelistedTargets[1], DeepSkyTargetList.whitelistedTargets[2]]
        TopThreeWidgetView(entry: TopThreeEntry(date: Date(), topThree: topThree))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
