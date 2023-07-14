//
//  Mac_DailyReportView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/5/23.
//

import SwiftUI

struct Mac_DailyReportView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
    @EnvironmentObject var store: HomeViewModel
    @State var report: DailyReport?
    @State var internet: Bool = true
    @State var isDateModal = false
    @State var isLocationModal = false
    @State var isReportSettingsModal = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if let report = report {
                    ReportHeader()
                    // Report Section
                    Mac_TopFiveView(report: report)
                        .padding()
                    HStack {
                        Mac_TopTenListView(reportList: report.topTenNebulae, targetTab: .nebulae)
                        Mac_TopTenListView(reportList: report.topTenGalaxies, targetTab: .galaxies)
                        Mac_TopTenListView(reportList: report.topTenStarClusters, targetTab: .starClusters)
                    }
                } else {
                    ProgressView("Generating Report")
                        .padding(.top, 50)
                    Spacer()
                }
            }
//            .toolbar {
//                ToolbarLogo()
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        isDateModal = true
//                    } label: {
//                        Image(systemName: "calendar")
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        isLocationModal = true
//                    } label: {
//                        Image(systemName: "location")
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        isReportSettingsModal = true
//                    } label: {
//                        Image(systemName: "slider.horizontal.3")
//                    }
//                }
//            }
            .navigationDestination(for: DeepSkyTarget.self) { target in
                Mac_DetailView(target: target)
                    .environmentObject(store)
            }
            
            // Modal for settings
//            .sheet(isPresented: $isDateModal){
//                ViewingIntervalModal()
//                    .environmentObject(store)
//                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
//            }
//            .sheet(isPresented: $isLocationModal){
//                LocationPickerModal()
//                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
//            }
//            .sheet(isPresented: $isReportSettingsModal){
//                DailyReportSettingsModal()
//                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
//            }
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
        .onChange(of: reportSettings.first?.minFOVCoverage) { _ in
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .onChange(of: reportSettings.first?.maxAllowedMoon) { _ in
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .onChange(of: reportSettings.first?.filterForMoonPhase) { _ in
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .onChange(of: reportSettings.first?.minVisibility) { _ in
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .onChange(of: reportSettings.first?.preferBroadband) { _ in
            self.report = nil
            Task {
                self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, preset: presetList.first(where: {$0.isSelected == true}), sunData: store.sunData)
            }
        }
        .navigationTitle("Daily Report")
        
    }
}

fileprivate struct ReportHeader: View {
    @EnvironmentObject var store: HomeViewModel
    
    var body: some View {
        VStack {
            Text("Daily Report")
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .fontWeight(.semibold)
            if store.viewingInterval == store.sunData.ATInterval {
                let dateFormatter: DateFormatter = {
                    let formatter = DateFormatter()
                    formatter.timeZone = store.location.timezone
                    formatter.dateStyle = .long
                    formatter.timeStyle = .none
                    return formatter
                }()
                Text("Night of \(dateFormatter.string(from: store.date)) | \(store.location.name)")
                    .font(.subheadline)
                    .fontWeight(.thin)
            } else {
                Text("\(store.viewingInterval.start.formatted(date: .abbreviated, time: .shortened)) to \(store.viewingInterval.end.formatted(date: .omitted, time: .shortened)) at \(store.location.name)")
                    .font(.subheadline)
                    .fontWeight(.thin)
            }
            let moonIllumination = Moon.getMoonIllumination(date: store.date, timezone: store.location.timezone)
            Text("Moon: \(moonIllumination.percent(sigFigs: 2)) illuminated")
                .font(.subheadline)
                .fontWeight(.thin)
        }.padding(.bottom)
    }
}
