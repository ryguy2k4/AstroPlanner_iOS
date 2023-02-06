//
//  Mac_DailyReportView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/5/23.
//

import SwiftUI

struct DailyReportView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @Binding var date: Date
    @State var report: DailyReport?
    @State var internet: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header Section
                ReportHeader()
                
                // Settings Section
                ReportSettingsEditor(date: $date)
                
                // Only display report if network data is available
                if let data = networkManager.data[.init(date: date, location: locationList.first!)] {
                    // every time the view refreshes, generate a report
                    let report = DailyReport(location: locationList.first!, date: date, reportSettings: reportSettings.first!, targetSettings: targetSettings.first!, presetList: presetList, data: data)
                    ScrollView {
                        VStack {
                            // Report Section
                            TopFiveView(report: report)
                            TopTenTabView(report: report)
                                .frame(height: 500)
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
                                try await networkManager.getData(at: locationList.first!, on: date)
                            } catch {
                                internet = false
                            }
                        }
                    } else {
                        Text("No Internet Connection")
                            .fontWeight(.bold)
                            .padding(.top)
                        Button("Retry") {
                            internet = true
                            Task {
                                do {
                                    try await networkManager.getData(at: locationList.first!, on: date)
                                } catch {
                                    internet = false
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
            .environmentObject(locationList.first!)
            .environmentObject(targetSettings.first!)
            .scrollIndicators(.hidden)
        }
    }
}

/**
 This View is a subview of DailyReportView that displays the topThree as defined withing the report.
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
                    Image(target.image?.source.fileName ?? "\(target.type.first!)")
                        .resizable()
                        .cornerRadius(12)
                        .aspectRatio(contentMode: .fit)
//                    NavigationLink(destination: DetailView(target: target).environmentObject(location).environmentObject(targetSettings)) {
//                        ZStack {
//                            Image(target.image?.source.fileName ?? "\(target.type.first!)")
//                                .resizable()
//                                .cornerRadius(12)
//                                .aspectRatio(contentMode: .fit)
//                                .scaledToFill()
//                            VStack {
//                                Text(target.name?[0] ?? target.defaultName)
//                                    .padding(2)
//                                    .background(.gray.opacity(0.8), in: Rectangle())
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.primary)
//                                Spacer()
//                            }
//                            .padding(4)
//                        }
//                    }
//                    NavigationLink(value: target) {

//                    }
                }
            }
            .frame(width: 368, height: 207)
            .navigationDestination(for: DeepSkyObject.self) { target in
                DetailView(target: target)
                    .environmentObject(location)
                    .environmentObject(targetSettings)
            }
        }
    }
}

/**
 This View is a TabView that uses a Segmented Picker to switch between tabs.
 Each Tab displays the 3 topFive arrays defined in the report.
 */
private struct TopTenTabView: View {
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var targetSettings: TargetSettings
    let report: DailyReport
    @State private var tabSelection: Int = 0
    
    var body: some View {
        VStack {
            Text("Top Ten")
                .fontWeight(.bold)
            Picker("Tab", selection: $tabSelection) {
                Text("Nebulae").tag(0)
                Text("Galaxies").tag(1)
                Text("Star Clusters").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            TabView(selection: $tabSelection) {
                if !report.topTenNebulae.isEmpty {
                    List(report.topTenNebulae) { target in
                        NavigationLink(destination: DetailView(target: target).environmentObject(location).environmentObject(targetSettings)) {
                            Text(target.name?[0] ?? target.defaultName)
                        }
                    }.tag(0).listStyle(.inset)
                } else {
                    VStack {
                        Text("No Nebulae")
                        Spacer()
                    }.tag(0)
                }
                if !report.topTenGalaxies.isEmpty {
                    List(report.topTenGalaxies) { target in
                        NavigationLink(destination: DetailView(target: target).environmentObject(location).environmentObject(targetSettings)) {
                            Text(target.name?[0] ?? target.defaultName)
                        }
                    }.tag(1).listStyle(.inset)
                } else {
                    VStack {
                        Text("No Galaxies")
                        Spacer()
                    }.tag(1)
                    
                }
                if !report.topTenStarClusters.isEmpty {
                    List(report.topTenStarClusters) { target in
                        NavigationLink(destination: DetailView(target: target).environmentObject(location).environmentObject(targetSettings)) {
                            Text(target.name?[0] ?? target.defaultName)
                        }
                    }.tag(2).listStyle(.inset)
                } else {
                    VStack {
                        Text("No Star Clusters")
                        Spacer()
                    }.tag(2)                }
            }
            .scrollDisabled(true)
        }
        .padding(.vertical)

    }
}

struct ReportHeader: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.date) var date
    @EnvironmentObject var location: SavedLocation
    var body: some View {
        VStack {
            Text("Daily Report")
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("\(date.formatted(date: .long, time: .omitted))")
                .font(.subheadline)
                .fontWeight(.thin)
            Text("Moon: \(networkManager.data[.init(date: date, location: location)]?.moon.illuminated.percent() ?? "%") illuminated")
                .font(.subheadline)
                .fontWeight(.thin)
        }.padding(.vertical)
    }
}

struct ReportSettingsEditor: View {
    @Environment(\.managedObjectContext) var context
    @Binding var date: Date
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    
    var body: some View {
        let presetBinding = Binding(
            get: { return presetList.first! },
            set: {
                for preset in presetList { preset.isSelected = false }
                $0.isSelected = true
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
                    ForEach(presetList) { preset in
                        Text(preset.name!).tag(preset)
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

