//
//  DailyReportView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/25/22.
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
            .environment(\.date, date)
            .scrollIndicators(.hidden)
            .navigationDestination(for: DeepSkyTarget.self) { target in
                DetailView(target: target)
                    .environmentObject(locationList.first!)
                    .environmentObject(targetSettings.first!)
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

/**
 The section of DailyReportView that contains the pickers for preset, location, and date
 */
fileprivate struct ReportSettingsEditor: View {
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
            DateSelector(date: $date)
            HStack {
                Picker("Imaging Preset", selection: presetBinding) {
                    Text("All").tag(-1)
                    ForEach(Array(presetList.enumerated()), id: \.element) { index, preset in
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
