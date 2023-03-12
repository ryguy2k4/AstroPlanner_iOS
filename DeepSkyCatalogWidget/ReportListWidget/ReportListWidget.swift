//
//  ReportListWidget.swift
//  ReportListWidget
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import WidgetKit
import SwiftUI

struct ReportListWidget: Widget {
    let kind: String = "ReportListWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ReportListIntent.self, provider: Provider()) { entry in
            ReportListView(entry: entry)
        }
        .configurationDisplayName("Top Targets")
        .description("This widget displays the top targets for today")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct ReportListView : View {
    var entry: ReportListEntry

    var body: some View {
        if let error = entry.error {
            Text("ERROR: \(error.localizedDescription)")
        } else {
            let rows = entry.targets.count < entry.rows ? entry.targets.count : entry.rows
            let targets = entry.targets.dropLast(entry.targets.count > rows ? entry.targets.count - rows : 0)
            
            VStack(alignment: .listRowSeparatorLeading, spacing: 5) {
                ForEach(targets) { target in
                    HStack {
                        let image = UIImage(named: target.image?.source.fileName ?? "\(target.type)")!.scalePreservingAspectRatio(targetSize: .init(width: 300, height: 300))
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                        Text(target.name?.first! ?? target.defaultName)
                            .font(.headline)
                            .fontWeight(.medium)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
            .padding(10)
        }
    }
}

struct ReportListWidget_Previews: PreviewProvider {
    static var previews: some View {
        ReportListView(entry: ReportListEntry.placeholder())
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
