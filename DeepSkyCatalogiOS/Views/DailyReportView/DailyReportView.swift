//
//  DailyReportView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/25/22.
//

import SwiftUI
import CoreData
import WeatherKit

struct DailyReportView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
    
    @Environment(\.location) var location
    @Environment(\.sunData) var sunData
    
    @Binding var date: Date
    @Binding var viewingInterval: DateInterval
    
    @State var report: DailyReport?
    @State var internet: Bool = true
    @State var isDateModal = false
    @State var isLocationModal = false
    @State var isReportSettingsModal = false
    @State var topTenTab: TargetTab = .nebulae
    
    var body: some View {
        NavigationStack {
            ReportHeader()
            ScrollView {
                if let report = DailyReport(location: location, date: date, viewingInterval: viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, presetList: Array(presetList), sunData: sunData) {
                    VStack {
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
                    .environment(\.location, location)
                    .environmentObject(targetSettings.first!)
                    .environment(\.viewingInterval, viewingInterval)
                    .environment(\.date, date)
            }
            
            // Modal for settings
            .sheet(isPresented: $isDateModal){
                ViewingIntervalModal(date: $date, viewingInterval: $viewingInterval)
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
        .environmentObject(targetSettings.first!)
        .environment(\.date, date)
        .environment(\.viewingInterval, viewingInterval)
    }
}

fileprivate struct ReportHeader: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.sunData) var sunData
    @Environment(\.date) var date
    @Environment(\.location) var location: Location
    @Environment(\.viewingInterval) var viewingInterval
    var body: some View {
        VStack {
            Text("\(sunData.ATInterval)")
            Text("Daily Report")
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .fontWeight(.semibold)
            if viewingInterval == sunData.ATInterval {
                Text("Night of \(date.formatted(format: "M dd, yyyy", timezone: location.timezone)) at \(location.name)")
                    .font(.subheadline)
                    .fontWeight(.thin)
            } else {
                Text("\(viewingInterval.start.formatted(date: .abbreviated, time: .shortened)) to \(viewingInterval.end.formatted(date: .omitted, time: .shortened)) at \(location.name)")
                    .font(.subheadline)
                    .fontWeight(.thin)
            }
            let moonIllumination = MoonData.getMoonIllumination(date: date)
            Text("Moon: \(moonIllumination.percent(sigFigs: 2)) illuminated")
                .font(.subheadline)
                .fontWeight(.thin)
        }.padding(.bottom)
    }
}
