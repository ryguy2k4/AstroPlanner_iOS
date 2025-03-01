//
//  Provider.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import Foundation
import WidgetKit
import SwiftData

struct Provider: IntentTimelineProvider {
    
//    let viewContext = PersistenceManager.shared.container.viewContext
//    var locationsFetchRequest: NSFetchRequest<SavedLocation> {
//        let request = SavedLocation.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(SortDescriptor(\SavedLocation.isSelected, order: .reverse)), NSSortDescriptor(SortDescriptor(\SavedLocation.name, order: .forward))]
//        return request
//    }
//    var presetFetchRequest: NSFetchRequest<ImagingPreset> {
//        let request = ImagingPreset.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(SortDescriptor(\ImagingPreset.isSelected, order: .reverse))]
//        return request
//    }
    
    func placeholder(in context: Context) -> ReportListEntry {
        return ReportListEntry.placeholder()
    }
    
    func getSnapshot(for configuration: ReportListIntent, in context: Context, completion: @escaping (ReportListEntry) -> Void) {
        completion(ReportListEntry.placeholder())
    }
    
    func getTimeline(for configuration: ReportListIntent, in context: Context, completion: @escaping (Timeline<ReportListEntry>) -> Void) {
        Task {
            do {
                
                // fetch core data configurations
//                let presetList = try viewContext.fetch(presetFetchRequest)
//                guard let location = try viewContext.fetch(locationsFetchRequest).first(where: {$0.name == configuration.location}) else {
//                    throw TimelineError.noLocations
//                }
//                guard let targetSettings = try viewContext.fetch(TargetSettings.fetchRequest()).first else {
//                    throw TimelineError.noTargetSettings
//                }
//                guard let reportSettings = try viewContext.fetch(ReportSettings.fetchRequest()).first else {
//                    throw TimelineError.noReportSettings
//                }
                
                // use current date
//                let currentDate: Date = .now.startOfLocalDay(timezone: TimeZone(identifier: location.timezone!)!)

                // generate sundata
//                let sunData = Sun.sol.getNextInterval(location: Location(saved: location), date: currentDate)

                // get viewing interval
//                let viewingInterval = {
//                    if reportSettings.darknessThreshold == Int16(2) {
//                        return sunData.CTInterval
//                    } else if reportSettings.darknessThreshold == Int16(1) {
//                        return sunData.NTInterval
//                    } else {
//                        return sunData.ATInterval
//                    }
//                }()
                
                // generate a report
//                let report = DailyReport(location: Location(saved: location), date: currentDate, viewingInterval: viewingInterval, reportSettings: reportSettings, targetSettings: targetSettings, preset: presetList.first(where: {$0.isSelected == true}), sunData: sunData)
                
                // create a timline with 1 entry for the current date
                var rows: Int {
                    switch configuration.rows {
                    case .one: return 1
                    case .two: return 2
                    case .three: return 3
                    case .unknown: return 3
                    }
                }
//                let entry = ReportListEntry(date: currentDate, targets: report.topFive, rows: rows)
                let entry = ReportListEntry.placeholder()
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            } 
//            catch {
//                // TEMPORARY -- CHANGE LATER
//                // if there are any problems fetching from core data, or making network calls, just use the placeholder data
//                let timeline = Timeline(entries: [ReportListEntry.placeholder(error: error)], policy: .atEnd)
//                completion(timeline)
//            }
        }
    }
}

enum TimelineError: Error {
    case noLocations
    case noTargetSettings
    case noReportSettings
    
    var localizedDescription: String {
        switch self {
        case .noLocations:
            return "No Locations"
        case .noTargetSettings:
            return "No Target Settings"
        case .noReportSettings:
            return "No Report Settings"
        }
    }
}
