//
//  Provider.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import Foundation
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TopThreeEntry {
        let topThree = [DeepSkyTargetList.whitelistedTargets.randomElement()!.value, DeepSkyTargetList.whitelistedTargets.randomElement()!.value, DeepSkyTargetList.whitelistedTargets.randomElement()!.value]
        return TopThreeEntry(date: Date(), topThree: topThree)
    }

    func getSnapshot(in context: Context, completion: @escaping (TopThreeEntry) -> ()) {
        let topThree = [DeepSkyTargetList.whitelistedTargets.randomElement()!.value, DeepSkyTargetList.whitelistedTargets.randomElement()!.value, DeepSkyTargetList.whitelistedTargets.randomElement()!.value]
        let entry = TopThreeEntry(date: Date(), topThree: topThree)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TopThreeEntry>) -> ()) {
            var entries: [TopThreeEntry] = []
            
        // Generate a timline with 1 entry for the current date
        //let report = DailyReport(location: locationList.first!, date: date, settings: reportSettings.first!, preset: presetList.first!, data: data)
        let topThree = [DeepSkyTargetList.whitelistedTargets.randomElement()!.value, DeepSkyTargetList.whitelistedTargets.randomElement()!.value, DeepSkyTargetList.whitelistedTargets.randomElement()!.value]
        let currentDate = Date()
        let entryDate = Calendar.current.startOfDay(for: currentDate)
        let entry = TopThreeEntry(date: entryDate, topThree: topThree)
        entries.append(entry)
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
