//
//  DeepSkyCatalogWidgetBundle.swift
//  ReportListWidget
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import WidgetKit
import SwiftUI

@main
struct DeepSkyCatalogWidgetBundle: WidgetBundle {
    var body: some Widget {
//        ReportListWidget()
        EmptyWidget()
    }
}

struct EmptyWidget: Widget {
    let kind: String = "empty"

    var body: some WidgetConfiguration {
        EmptyWidgetConfiguration()
    }
}
