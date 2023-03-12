//
//  Provider.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import Foundation
import WidgetKit
import CoreData

struct Provider: IntentTimelineProvider {
    
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
    
    func placeholder(in context: Context) -> ReportListEntry {
        return ReportListEntry.placeholder
    }
    
    func getSnapshot(for configuration: ReportListIntent, in context: Context, completion: @escaping (ReportListEntry) -> Void) {
        completion(ReportListEntry.placeholder)
    }
    
    func getTimeline(for configuration: ReportListIntent, in context: Context, completion: @escaping (Timeline<ReportListEntry>) -> Void) {
        Task {
            do {
                // use current date
                let currentDate = Date().startOfDay()
                
                // fetch core data configurations
                let location = try viewContext.fetch(locationsFetchRequest).first(where: {$0.name == configuration.location})!
                let presetList = try viewContext.fetch(presetFetchRequest)
                let targetSettings = try viewContext.fetch(TargetSettings.fetchRequest()).first!
                let reportSettings = try viewContext.fetch(ReportSettings.fetchRequest()).first!
                
                // fetch sun and moon data from network
                let data = try await NetworkManager.shared.getData(at: location, on: currentDate)
                
                // generate a report
                let report = DailyReport(location: location, date: currentDate, viewingInterval: data.sun.ATInterval, reportSettings: reportSettings, targetSettings: targetSettings, presetList: presetList, data: data)
                
                // create a timline with 1 entry for the current date
                var rows: Int {
                    switch configuration.rows {
                    case .one: return 1
                    case .two: return 2
                    case .three: return 3
                    case .unknown: return 3
                    }
                }
                let entry = ReportListEntry(date: currentDate, targets: report.topFive, rows: rows)
                let timeline = Timeline(entries: [entry], policy: .after(data.sun.ATInterval.end))
                completion(timeline)
            } catch {
                // TEMPORARY -- CHANGE LATER
                // if there are any problems fetching from core data, or making network calls, just use the placeholder data
                let timeline = Timeline(entries: [ReportListEntry.placeholder], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}
