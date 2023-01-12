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
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @Binding var date: Date
    @State var report: DailyReport?
    
    var body: some View {
        let presetBinding = Binding(
            get: { return presetList.first! },
            set: {
                for preset in presetList { preset.isSelected = false }
                $0.isSelected = true
            }
        )
        let locationBinding = Binding(
            get: { return locationList.first! },
            set: {
                for location in locationList { location.isSelected = false }
                $0.isSelected = true
            }
        )
        
        // Only display report if network data is available
        if let data = networkManager.data[.init(date: date, location: locationList.first!)] {
            // every time the view refreshes, generate a report
            let report = DailyReport(location: locationList.first!, date: date, settings: reportSettings.first!, presetList: presetList, data: data)
            NavigationView {
                ScrollView {
                    VStack() {
                        VStack {
                            Text("Daily Report")
                                .multilineTextAlignment(.center)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                            Text("\(date.formatted(date: .long, time: .omitted))")
                                .font(.subheadline)
                                .fontWeight(.thin)
                            Text("Moon: \(networkManager.data[.init(date: date, location: locationList.first!)]?.moon.illuminated.percent() ?? "%") illuminated")
                                .font(.subheadline)
                                .fontWeight(.thin)
                        }
                            .padding(.vertical)
                        DateSelector(date: $date)
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
                        Text("Reccomended Scope: ")
                        TopFiveView(report: report)
                        TopTenTabView(report: report)
                            .frame(height: 500)
                    }
                }
                .environmentObject(locationList.first!)
                .environmentObject(reportSettings.first!)
                .scrollIndicators(.hidden)
            }
        }
        
        // Otherwise show a loading screen and request the necessary data
        else {
            VStack {
                ProgressView()
                Text("Fetching Data...")
            }
            .task {
                await networkManager.getData(at: locationList.first!, on: date)
            }
        }
    }
}

/**
 This View is a subview of DailyReportView that displays the topThree as defined withing the report.
 */
private struct TopFiveView: View {
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var reportSettings: ReportSettings
    let report: DailyReport
    
    var body: some View {
        VStack {
            Text("Top Five Overall")
                .fontWeight(.bold)
            TabView {
                ForEach(report.topFive, id: \.id) { target in
                    NavigationLink(destination: DetailView(target: target).environmentObject(location).environmentObject(reportSettings)) {
                        ZStack {
                            Image(target.image)
                                .resizable()
                                .cornerRadius(12)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 368, height: 207)
                            VStack {
                                Text(target.name[0])
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

/**
 This View is a TabView that uses a Segmented Picker to switch between tabs.
 Each Tab displays the 3 topFive arrays defined in the report.
 */
private struct TopTenTabView: View {
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var reportSettings: ReportSettings
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
                        NavigationLink(destination: DetailView(target: target).environmentObject(location).environmentObject(reportSettings)) {
                            Text(target.name.first!)
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
                        NavigationLink(destination: DetailView(target: target).environmentObject(location).environmentObject(reportSettings)) {
                            Text(target.name.first!)
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
                        NavigationLink(destination: DetailView(target: target).environmentObject(location).environmentObject(reportSettings)) {
                            Text(target.name.first!)
                        }
                    }.tag(2).listStyle(.inset)
                } else {
                    VStack {
                        Text("No Star Clusters")
                        Spacer()
                    }.tag(2)                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .scrollDisabled(true)
        }
        .padding(.vertical)

    }
}

//struct DailyReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyReportView()
//    }
//}

