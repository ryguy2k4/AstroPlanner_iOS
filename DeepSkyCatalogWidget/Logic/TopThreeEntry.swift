//
//  TopThreeEntry.swift
//  DeepSkyCatalogWidgetExtension
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import Foundation
import WidgetKit

struct TopThreeEntry: TimelineEntry {
    let date: Date
    let topThree: [DeepSkyObject]
}
