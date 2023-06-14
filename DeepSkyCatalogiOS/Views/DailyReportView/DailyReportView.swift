//
//  DailyReportView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/25/22.
//

import SwiftUI
import CoreData
import WeatherKit
import CoreLocation

struct DailyReportView: View {
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
    @State var topTenTab: TargetTab = .nebulae

    var body: some View {
        NavigationStack {
            VStack {
                ReportHeader()
                ScrollView {
                    VStack {
                        if let report = report {
                            // Report Section
                            TopFiveView(report: report)
                            TopTenTabView(report: report, tabSelection: $topTenTab)
                                .onAppear() {
                                    if report.topTenNebulae.isEmpty { topTenTab = .starClusters }
                                    else if report.topTenGalaxies.isEmpty { topTenTab = .galaxies }
                                }
                        }
                    }
                }
                .toolbar {
                    ToolbarLogo()
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isReportSettingsModal = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
                .navigationDestination(for: DeepSkyTarget.self) { target in
                    DetailView(target: target)
                        .environment(\.location, store.location)
                        .environment(\.viewingInterval, store.viewingInterval)
                        .environment(\.date, store.date)
                }
                
                // Modal for settings
                .sheet(isPresented: $isDateModal){
                    ViewingIntervalModal()
                        .environmentObject(store)
                        .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
                }
                .sheet(isPresented: $isLocationModal){
                    LocationPickerModal()
                        .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
                }
                .sheet(isPresented: $isReportSettingsModal){
                    DailyReportSettingsModal()
                        .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
                }
                .scrollIndicators(.hidden)
                
            }
        }
        .environment(\.date, store.date)
        .environment(\.viewingInterval, store.viewingInterval)
        .environmentObject(store)
        .onAppear {
            self.report = DailyReport(location: store.location, date: store.date, viewingInterval: store.viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, presetList: Array(presetList), sunData: store.sunData)
        }
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
            let moonIllumination = MoonData.getMoonIllumination(date: store.date, timezone: store.location.timezone)
            Text("Moon: \(moonIllumination.percent(sigFigs: 2)) illuminated")
                .font(.subheadline)
                .fontWeight(.thin)
        }.padding(.bottom)
    }
}
