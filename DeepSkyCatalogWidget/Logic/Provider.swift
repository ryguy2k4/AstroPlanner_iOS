//
//  Provider.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import Foundation
import WidgetKit
import CoreData

struct Provider: TimelineProvider {
    
    let viewContext = PersistenceManager.shared.container.viewContext
    var locationsFetchRequest: NSFetchRequest<SavedLocation> {
        let request = SavedLocation.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(SortDescriptor(\SavedLocation.isSelected, order: .reverse)), NSSortDescriptor(SortDescriptor(\SavedLocation.name, order: .forward))]
        return request
    }
    var presetFetchRequest: NSFetchRequest<ImagingPreset> {
        let request = ImagingPreset.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(SortDescriptor(\ImagingPreset.isSelected, order: .reverse))]
        return request
    }
    
    func placeholder(in context: Context) -> TopThreeEntry {
        return TopThreeEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (TopThreeEntry) -> ()) {
        completion(TopThreeEntry.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TopThreeEntry>) -> ()) {
        Task {
            do {
                // use current date
                let currentDate = Date().startOfDay()
                
                // fetch core data configurations
                let location = try viewContext.fetch(locationsFetchRequest).first!
                let presetList = try viewContext.fetch(presetFetchRequest)
                let targetSettings = try viewContext.fetch(TargetSettings.fetchRequest()).first!
                let reportSettings = try viewContext.fetch(ReportSettings.fetchRequest()).first!
                
                // fetch sun and moon data from network
                let data = try await NetworkManager.shared.getData(at: location, on: currentDate)
                
                // generate a report
                let report = DailyReport(location: location, date: currentDate, viewingInterval: data.sun.ATInterval, reportSettings: reportSettings, targetSettings: targetSettings, presetList: presetList, data: data)
                
                // create a timline with 1 entry for the current date
                let entry = TopThreeEntry(date: currentDate, topThree: report.topFive.dropLast(2))
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            } catch {
                // TEMPORARY -- CHANGE LATER
                // if there are any problems fetching from core data, or making network calls, just use the placeholder data
                let timeline = Timeline(entries: [TopThreeEntry.placeholder], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}
