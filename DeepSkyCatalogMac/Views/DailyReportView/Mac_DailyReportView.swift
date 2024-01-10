//
//  Mac_DailyReportView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/5/23.
//

import SwiftUI
import SwiftData

struct Mac_DailyReportView: View {
    @EnvironmentObject var store: HomeViewModel

    @Query var reportSettings: [ReportSettings]
    @Query var targetSettings: [TargetSettings]
    @Query var presetList: [ImagingPreset]
    
    @State var report: DailyReport?
    @State var isDateModal = false
    @State var isLocationModal = false
    @State var isImagingPresetModal = false
    @State var topTenTab: TargetTab = .nebulae
    
    @State var selection: DeepSkyTarget?
    

    var body: some View {
        NavigationSplitView {
            ScrollView {
                if let report = report {
                    // Report Section
                    Mac_TopFiveView(report: report, selection: $selection)
                        .padding()
                    HStack {
                        Mac_TopTenListView(reportList: report.topTenNebulae, targetTab: .nebulae, selection: $selection)
                        Mac_TopTenListView(reportList: report.topTenGalaxies, targetTab: .galaxies, selection: $selection)
                        Mac_TopTenListView(reportList: report.topTenStarClusters, targetTab: .starClusters, selection: $selection)
                    }
                } else {
                    ProgressView("Generating Report")
                        .padding(.top, 50)
                    Spacer()
                }
            }
        } detail: {
            if let selection = selection {
                Mac_DetailView(target: selection)
                    .environmentObject(store)
                    .navigationSplitViewColumnWidth(min: 400, ideal: 400)
            } else {
                ContentUnavailableView("Nil", systemImage: "camera")
                    .navigationSplitViewColumnWidth(min: 0, ideal: 0, max: 0)
            }
            
        }
        .scrollIndicators(.hidden)
        .environmentObject(store)
        .task {
            self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
        }
        
         // update report on preset change
        .onChange(of: presetList.first(where: {$0.isSelected == true})) {
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        // update report on settings changes
        .onChange(of: reportSettings.first?.minFOVCoverage) {
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .onChange(of: reportSettings.first?.maxAllowedMoon) {
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .onChange(of: reportSettings.first?.filterForMoonPhase) {
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .onChange(of: reportSettings.first?.minVisibility) {
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .onChange(of: reportSettings.first?.preferBroadband) { _, _ in
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .navigationTitle("Daily Report | " + (store.viewingInterval == store.sunData.ATInterval ? "Night of \(DateFormatter.longDateOnly(timezone: store.location.timezone).string(from: store.date)) | \(store.location.name)" : "\(store.viewingInterval.start.formatted(date: .abbreviated, time: .shortened)) to \(store.viewingInterval.end.formatted(date: .omitted, time: .shortened)) at \(store.location.name)") + " | ☾ \(Moon.getMoonIllumination(date: store.date).percent(sigFigs: 2)) illuminated")
    }
}
