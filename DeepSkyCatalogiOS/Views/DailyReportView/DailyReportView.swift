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
    @EnvironmentObject var store: HomeViewModel

    @Query var reportSettings: [ReportSettings]
    @Query var targetSettings: [TargetSettings]
    @Query var presetList: [ImagingPreset]
    
    @State var report: DailyReport?
    @State var isDateModal = false
    @State var isLocationModal = false
    @State var isImagingPresetModal = false

    var body: some View {
        NavigationStack {
            VStack {
                if let report = report {
                    ScrollView {
                        // iOS VIEW
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            iOS_DailyReportView( report: report, reportHeader: reportHeader())
                        }
                        // iPad VIEW
                        else {
                            iPad_DailyReportView(report: report, reportHeader: reportHeader())
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
            .scrollIndicators(.hidden)
            .navigationDestination(for: DeepSkyTarget.self) { target in
                DetailView(target: target)
            }
            
            // Modals for settings
            .sheet(isPresented: $isDateModal){
                ViewingIntervalModal(reportSettings: reportSettings.first!)
                    .environmentObject(store)
                    .environment(\.timeZone, store.location.timezone)
                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
                    .onDisappear() {
                        Task {
                            self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
                        }
                    }
            }
            .sheet(isPresented: $isLocationModal){
                LocationPickerModal()
                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
            }
            .sheet(isPresented: $isImagingPresetModal){
                ImagingPresetModal()
                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
            }
            
            // Start generating a report on a background thread when this view appears
            .task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
            
            // Update report on settings changes
            .onChange(of: presetList.first(where: {$0.isSelected == true})) {
                self.report = nil
                Task {
                    self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
                }
            }
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
        }
    }
    
    /**
     This function returns a string to be used as a header or title for this view.
     */
    func reportHeader() -> String {
        if store.viewingInterval == store.sunData.ATInterval || store.viewingInterval == store.sunData.NTInterval || store.viewingInterval == store.sunData.CTInterval {
            return " ☾ \(Moon.getMoonIllumination(date: store.date).percent(sigFigs: 2)) | Night of \(DateFormatter.longDateOnly(timezone: store.location.timezone).string(from: store.date)) | \(store.location.name)"
        }
        else {
            return " ☾ \(Moon.getMoonIllumination(date: store.date).percent(sigFigs: 2)) | \(store.viewingInterval.start.formatted(date: .abbreviated, time: .shortened)) to \(store.viewingInterval.end.formatted(date: .omitted, time: .shortened)) | \(store.location.name)"
        }
    }
}
