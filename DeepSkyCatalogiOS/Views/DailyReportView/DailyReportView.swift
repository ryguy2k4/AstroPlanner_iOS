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
        if let location = locationList.first {
            let data = networkManager.data[.init(date: date, location: location)]
            
            NavigationStack {
                VStack {
                    // Header Section
                    Text("Daily Report")
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    
                    // Only display report if network data is available
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
                    // If Network data is not fetched, show a loading screen and then request the necessary data
                    else {
                        if internet {
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
                        } else {
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
                        .environmentObject(locationList.first!)
                        .environmentObject(targetSettings.first!)
                }
            }
            .environmentObject(location)
            .environmentObject(targetSettings.first!)
            .environment(\.date, date)
            .environment(\.viewingInterval, viewingInterval)
            .scrollIndicators(.hidden)
            .sheet(isPresented: $isSettingsModal) {
                DailyReportSettings(date: $date, viewingInterval: $viewingInterval)
                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
                    .disabled(data == nil)
                    .environment(\.data, data)
            }
            .onChange(of: data?.sun.ATInterval) { newInterval in
                if let newInterval = newInterval {
                    viewingInterval = newInterval
                    print(newInterval)
                }
            }
        }
        // if there is no location stored, then prompt the user to create one
        else {
            NavigationStack {
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
    }
}

/**
 This View is a subview of DailyReportView that displays the topThree as defined within the report.
 */
private struct TopFiveView: View {
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var targetSettings: TargetSettings
    let report: DailyReport
    
    var body: some View {
        VStack {
            Text("Top Five Overall")
                .fontWeight(.bold)
            TabView {
                ForEach(report.topFive, id: \.id) { target in
                    NavigationLink(value: target) {
                        ZStack {
                            Image(target.image?.source.fileName ?? "\(target.type)")
                                .resizable()
                                .cornerRadius(12)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 368, height: 207)
                            VStack {
                                Text(target.name?[0] ?? target.defaultName)
                                    .padding(2)
                                    .background(.gray.opacity(0.8), in: Rectangle())
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(4)
                        }
                    }
                }
            }
            .frame(width: 368, height: 207)
            .tabViewStyle(.page)
        }
    }
}

fileprivate struct ReportHeader: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.data) var data
    @Environment(\.date) var date
    @Environment(\.viewingInterval) var viewingInterval
    @EnvironmentObject var location: SavedLocation
    var body: some View {
        VStack {
            if viewingInterval == data?.sun.ATInterval {
                Text("Night of \(date.formatted(date: .long, time: .omitted))")
                    .font(.subheadline)
                    .fontWeight(.thin)
            } else {
                Text("\(viewingInterval.start.formatted(date: .abbreviated, time: .shortened)) to \(viewingInterval.end.formatted(date: .omitted, time: .shortened))")
                    .font(.subheadline)
                    .fontWeight(.thin)
            }
            if let moon = data?.moon {
                let moonOverlap = (moon.moonInterval.intersection(with: viewingInterval)?.duration ?? 0) / viewingInterval.duration
                Text("Moon: \(moon.illuminated.percent()) illuminated for \(moonOverlap.percent()) of the night")
                    .font(.subheadline)
                    .fontWeight(.thin)
            }
        }.padding(.bottom)
    }
}
