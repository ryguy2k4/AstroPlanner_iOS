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
    @State var topTenTab: TargetTab = .nebulae

    var body: some View {
        NavigationStack {
            VStack {
                if let report = report {
                    ReportHeader()
                    ScrollView {
                        // Report Section
                        TopFiveView(report: report)
                        TopTenTabView(report: report, tabSelection: $topTenTab)
                            .onAppear() {
                                if report.topTenNebulae.isEmpty { topTenTab = .galaxies }
                                else if report.topTenNebulae.isEmpty && report.topTenGalaxies.isEmpty { topTenTab = .starClusters }
                            }
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


struct ReportSettingsEditor: View {
    @Environment(\.managedObjectContext) var context
    @Binding var date: Date
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    
    var body: some View {
        let presetBinding = Binding(
            get: { return presetList.firstIndex(where: {$0.isSelected == true}) ?? -1 },
            set: {
                for preset in presetList { preset.isSelected = false }
                if $0 >= 0 {
                    presetList[$0].isSelected = true
                }
                PersistenceManager.shared.saveData(context: context)
            }
        )
        let locationBinding = Binding(
            get: { return locationList.first! },
            set: {
                for location in locationList { location.isSelected = false }
                $0.isSelected = true
                PersistenceManager.shared.saveData(context: context)
            }
        )
        VStack {
//            DateSelector(date: $date)
            HStack {
                Picker("Imaging Preset", selection: presetBinding) {
                    Text("All").tag(-1)
                    ForEach(presetList.indices) { index in
                        Text(presetList[index].name!).tag(index)
                    }
                }
                Picker("Location", selection: locationBinding) {
                    ForEach(locationList) { location in
                        Text(location.name!).tag(location)
                    }
                }
            }
        }
    }
}

/**
 This View is a subview of DailyReportView that displays the topThree as defined within the report.
 */
struct TopFiveView: View {
    let report: DailyReport
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(report.topFive, id: \.id) { target in
                    NavigationLink(value: target) {
                        VStack {
                            Text(target.name?[0] ?? target.defaultName)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Image(target.image?.source.fileName ?? "\(target.type)")
                                .resizable()
                                .cornerRadius(12)
                                .aspectRatio(contentMode: .fit)
                                .scaledToFill()
                                .frame(width: 368, height: 207)
                        }
                    }
                }
            }
        }
    }
}

enum TargetTab: String, Identifiable, CaseIterable {
    var id: Self { self }
    case nebulae = "Nebulae"
    case galaxies = "Galaxies"
    case starClusters = "Star Clusters"
}

/**
 This View is a TabView that uses a Segmented Picker to switch between tabs.
 Each Tab displays the 3 topFive arrays defined in the report.
 */
struct TopTenTabView: View {
    let report: DailyReport
    
    @Binding var tabSelection: TargetTab
    
    var body: some View {
        VStack {
            Picker("Tab", selection: $tabSelection) {
                ForEach(TargetTab.allCases) { tab in
                    Text(tab.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            
            TabView(selection: $tabSelection) {
                TopTenListView(reportList: report.topTenNebulae, targetTab: .nebulae)
                TopTenListView(reportList: report.topTenGalaxies, targetTab: .galaxies)
                TopTenListView(reportList: report.topTenStarClusters, targetTab: .starClusters)
            }
        }
        .scrollDisabled(true)
        .padding(.vertical)
        .frame(minHeight: 500)
    }
}

fileprivate struct TopTenListView: View {
    let reportList: [DeepSkyTarget]
    let targetTab: TargetTab
    
    var body: some View {
        if !reportList.isEmpty {
            List(reportList) { target in
                NavigationLink(value: target) {
                    Text(target.name?[0] ?? target.defaultName)
                }
            }.tag(targetTab).listStyle(.inset)
        } else {
            VStack {
                Spacer()
                Text("No \(targetTab.rawValue) :/")
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }.tag(targetTab)
        }
    }
}

