//
//  DailyReportView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/25/22.
//

import SwiftUI
import CoreData

struct DailyReportView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @Binding var date: Date
    @Binding var viewingInterval: DateInterval
    @State var report: DailyReport?
    @State var internet: Bool = true
    @State var isSettingsModal = false
    
    var body: some View {
        NavigationStack {
            let location: Location? = {
                if let selected = locationList.first(where: { $0.isSelected == true }) {
                    // try to find a selected location
                    return Location(saved: selected)
                } else if locationManager.locationEnabled, let latest = locationManager.latestLocation {
                    // try to get the current location
                    return Location(current: latest)
                } else if let any = locationList.first {
                    // try to find any location
                    any.isSelected = true
                    return Location(saved: any)
                } else {
                    // no location found
                    return nil
                }
            }()
            
            if let location = location {
                let data = networkManager.data[.init(date: date, location: location)]
                VStack {
                    // header
                    Text("Daily Report")
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    // display report if network data is available
                    if let data = data, let report = DailyReport(location: location, date: date, viewingInterval: viewingInterval, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, presetList: Array(presetList), data: data) {
                        
                        ReportHeader()
                            .environment(\.data, data)
                        ScrollView {
                            VStack {
                                // Report Section
                                TopFiveView(report: report)
                                let tabToShow: TargetTab = {
                                    // show first non-empty tab
                                    if !report.topTenNebulae.isEmpty { return .nebulae }
                                    else if !report.topTenGalaxies.isEmpty { return .galaxies }
                                    else if !report.topTenStarClusters.isEmpty { return .starClusters }
                                    else { return .nebulae }
                                }()
                                TopTenTabView(report: report, tabSelection: tabToShow)
                            }
                        }
                    }
                    // if network data is unavailable, show loading or failure screen
                    else {
                        if internet {
                            DailyReportLoadingView(internet: $internet)
                        } else {
                            DailyReportLoadingFailedView(internet: $internet)
                        }
                    }
                }
                .toolbar {
                    ToolbarLogo()
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isSettingsModal = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
                .navigationDestination(for: DeepSkyTarget.self) { target in
                    DetailView(target: target)
                        .environment(\.location, location)
                        .environmentObject(targetSettings.first!)
                }
                .environment(\.location, location)
                .environmentObject(targetSettings.first!)
                .environment(\.date, date)
                .environment(\.viewingInterval, viewingInterval)
                .scrollIndicators(.hidden)
                .sheet(isPresented: $isSettingsModal) {
                    DailyReportSettingsModal(date: $date, viewingInterval: $viewingInterval)
                        .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
                        .disabled(data == nil)
                        .environment(\.data, data)
                }
                .onChange(of: data?.sun.ATInterval) { newInterval in
                    if let newInterval = newInterval {
                        viewingInterval = newInterval
                    }
                }
            }
            // if there is no location stored, then prompt the user to create one
            else {
                DailyReportNoLocationsView()
            }
        }
    }
}

fileprivate struct ReportHeader: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.data) var data
    @Environment(\.date) var date
    @Environment(\.location) var location: Location
    @Environment(\.viewingInterval) var viewingInterval
    var body: some View {
        VStack {
            if viewingInterval == data?.sun.ATInterval {
                Text("Night of \(date.formatted(date: .long, time: .omitted)) at \(location.name)")
                    .font(.subheadline)
                    .fontWeight(.thin)
            } else {
                Text("\(viewingInterval.start.formatted(date: .abbreviated, time: .shortened)) to \(viewingInterval.end.formatted(date: .omitted, time: .shortened)) at \(location.name)")
                    .font(.subheadline)
                    .fontWeight(.thin)
            }
            if let moon = data?.moon {
                Text("Moon: \(moon.illuminated.percent(sigFigs: 2)) illuminated")
                    .font(.subheadline)
                    .fontWeight(.thin)
            }
        }.padding(.bottom)
    }
}

fileprivate struct DailyReportLoadingView: View {
    @Environment(\.date) var date
    @Environment(\.location) var location: Location
    @EnvironmentObject var networkManager: NetworkManager
    @Binding var internet: Bool
    var body: some View {
        VStack {
            ProgressView()
                .padding(.top)
            Text("Fetching Sun/Moon Data...")
                .fontWeight(.bold)
            Spacer()
        }
        .task {
            do {
                try await networkManager.updateData(at: location, on: date)
            } catch {
                internet = false
            }
        }
    }
}

fileprivate struct DailyReportLoadingFailedView: View {
    @Environment(\.date) var date
    @Environment(\.location) var location: Location
    @EnvironmentObject var networkManager: NetworkManager
    @Binding var internet: Bool
    var body: some View {
        VStack {
            Text("Daily Report Unavailable Offline")
                .fontWeight(.bold)
                .padding(.vertical)
            Button("Retry") {
                internet = true
                Task {
                    do {
                        try await networkManager.updateData(at: location, on: date)
                    } catch {
                        internet = false
                    }
                }
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "wifi.exclamationmark")
                    .foregroundColor(.red)
            }
        }
    }
}

fileprivate struct DailyReportNoLocationsView: View {
    var body: some View {
        VStack {
            Text("Add a Location")
                .fontWeight(.semibold)
            NavigationLink(destination: LocationSettings()) {
                Label("Locations Settings", systemImage: "location")
            }
            .padding()
        }
    }
}
