//
//  DailyReportView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/25/22.
//

import SwiftUI
import SwiftData
import CoreLocation

struct DailyReportView: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    @Query var reportSettings: [ReportSettings]
    @Query var targetSettings: [TargetSettings]
    @Query var presetList: [ImagingPreset]
    @EnvironmentObject var store: HomeViewModel
    @State var report: DailyReport?
    @State var internet: Bool = true
    @State var isDateModal = false
    @State var isLocationModal = false
    @State var isImagingPresetModal = false
    @State var topTenTab: TargetTab = .nebulae

    var body: some View {
        NavigationStack {
            VStack {
                if let report = report {
                    ScrollView {
                        // iOS VIEW
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            Text(reportHeader())
                                .font(.subheadline)
                                .lineLimit(1)
                                .padding(5)
                            TopFiveView(report: report)
                            TopTenTabView(report: report, tabSelection: $topTenTab)
                                .onAppear() {
                                    if report.topTenNebulae.isEmpty { topTenTab = .galaxies }
                                    else if report.topTenNebulae.isEmpty && report.topTenGalaxies.isEmpty { topTenTab = .starClusters }
                                }
                        }
                        // iPad VIEW
                        else {
                            iPad_TopFiveView(report: report)
                            Divider()
                            HStack {
                                iPad_TopTenListView(reportList: report.topTenNebulae, targetTab: .nebulae)
                                iPad_TopTenListView(reportList: report.topTenGalaxies, targetTab: .galaxies)
                                iPad_TopTenListView(reportList: report.topTenStarClusters, targetTab: .starClusters)
                            }
                        }

                    }
                } else {
                    ProgressView("Generating Report")
                        .padding(.top, 50)
                    Spacer()
                }
            }
            .toolbar {
                ToolbarLogo()
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isImagingPresetModal = true
                    } label: {
                        Image(systemName: "camera.aperture")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isDateModal = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isLocationModal = true
                    } label: {
                        Image(systemName: "location")
                    }
                }
            }
            .navigationDestination(for: DeepSkyTarget.self) { target in
                DetailView(target: target)
            }
            .navigationTitle(UIDevice.current.userInterfaceIdiom == .pad ? reportHeader() : "")
            .navigationBarTitleDisplayMode(.inline)
            
            // Modal for settings
            .sheet(isPresented: $isDateModal){
                ViewingIntervalModal(reportSettings: reportSettings.first!)
                    .environmentObject(store)
                    .environment(\.timeZone, store.location.timezone)
                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
            }
            .sheet(isPresented: $isLocationModal){
                LocationPickerModal()
                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
            }
            .sheet(isPresented: $isImagingPresetModal){
                ImagingPresetModal()
                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
            }
            .scrollIndicators(.hidden)
                
        }
        .environmentObject(store)
        .task {
            self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
        }
        
        // update report on preset change
        .onReceive(presetList.publisher) { _ in
            let newPreset = presetList.first(where: {$0.isSelected == true})
            if newPreset != report?.preset {
                self.report = nil
                Task {
                    self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
                }
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
        .onChange(of: reportSettings.first?.preferBroadband) {
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .onChange(of: reportSettings.first?.darknessThreshold) { _, newValue in
            self.report = nil
            if newValue == 2 {
                store.viewingInterval = store.sunData.CTInterval
            } else if newValue == 1 {
                store.viewingInterval = store.sunData.NTInterval
            } else {
                store.viewingInterval = store.sunData.ATInterval
            }
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
    }
    
    func reportHeader() -> String {
        if store.viewingInterval == store.sunData.ATInterval || store.viewingInterval == store.sunData.NTInterval || store.viewingInterval == store.sunData.CTInterval {
            return " ☾ \(Moon.getMoonIllumination(date: store.date, timezone: store.location.timezone).percent(sigFigs: 2)) | Night of \(DateFormatter.longDateOnly(timezone: store.location.timezone).string(from: store.date)) | \(store.location.name)"
        }
        else {
            return " ☾ \(Moon.getMoonIllumination(date: store.date, timezone: store.location.timezone).percent(sigFigs: 2)) | \(store.viewingInterval.start.formatted(date: .abbreviated, time: .shortened)) to \(store.viewingInterval.end.formatted(date: .omitted, time: .shortened)) | \(store.location.name)"
        }
    }
}
