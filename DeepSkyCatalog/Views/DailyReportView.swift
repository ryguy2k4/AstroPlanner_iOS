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
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    VStack {
                        Text("Daily Report")
                            .multilineTextAlignment(.center)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Text("\(date.formatted(format: "MMMM d, y"))")
                            .font(.subheadline)
                            .fontWeight(.thin)
                        Text("Moon: \(networkManager.data[.init(date: date, location: locationList.first!)]?.moon.illuminated.percent() ?? "%") illuminated")
                            .font(.subheadline)
                            .fontWeight(.thin)
                    }
                        .padding(.top)
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
                    TopThreeView(report: report)
                    TopFiveTabView(report: report).frame(height: 500)
                }
            }
            .environmentObject(locationList.first!)
            .scrollIndicators(.hidden)
            .onChange(of: networkManager.isSafe) { isSafe in
                if isSafe {
                    Task {
                        report = DailyReport(location: locationList.first!, date: date, settings: reportSettings.first!, preset: presetList.first!)
                    }
                }
            }
            .onChange(of: presetList.first) { _ in
                Task {
                    report = DailyReport(location: locationList.first!, date: date, settings: reportSettings.first!, preset: presetList.first!)
                }
            }
            .onChange(of: locationList.first) { _ in
                Task {
                    report = DailyReport(location: locationList.first!, date: date, settings: reportSettings.first!, preset: presetList.first!)
                }
            }
            .onChange(of: date) { newDate in
                report = nil
                Task {
                    report = DailyReport(location: locationList.first!, date: newDate, settings: reportSettings.first!, preset: presetList.first!)
                }
            }
        }
    }
}

/**
 This View is a subview of DailyReportView that displays the topThree as defined withing the report.
 */
private struct TopThreeView: View {
    @EnvironmentObject var location: SavedLocation
    let report: DailyReport?
    
    var body: some View {
        VStack {
            Text("Top Three Overall")
                .fontWeight(.bold)
            TabView {
                if let report = report {
                    ForEach(report.topThree, id: \.id) { target in
                        NavigationLink(destination: DetailView(target: target).environmentObject(location)) {
                            let nameWidth = target.name[0].widthOfString(usingFont: .systemFont(ofSize: 20))
                            let nameHeight = target.name[0].heightOfString(usingFont: .systemFont(ofSize: 20))
                            ZStack {
                                Image(target.image[0])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 368, height: 207)
                                Rectangle()
                                    .size(width: nameWidth + 5, height: 32)
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                                Text(target.name[0])
                                    .fontWeight(.semibold)
                                    .position(x: nameWidth/2, y: nameHeight/2 + 3)
                                    .foregroundColor(.primary)
                                    .padding(2)
                            }
                        }
                    }
                }
                else {
                    ProgressView()
               }
            }
            .frame(width: 368, height: 207)
            .border(.primary)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
}

/**
 This View is a TabView that uses a Segmented Picker to switch between tabs.
 Each Tab displays the 3 topFive arrays defined in the report.
 */
private struct TopFiveTabView: View {
    @EnvironmentObject var location: SavedLocation
    let report: DailyReport?
    @State private var tabSelection: Int = 0
    
    var body: some View {
        VStack {
            Text("Top Five")
                .fontWeight(.bold)
            Picker("Tab", selection: $tabSelection) {
                Text("Nebulae").tag(0)
                Text("Galaxies").tag(1)
                Text("Star Clusters").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            if let report = report {
                TabView(selection: $tabSelection) {
                    List(report.topFiveNebulae) { target in
                        NavigationLink(destination: DetailView(target: target).environmentObject(location)) {
                            Text(target.name.first!)
                        }
                    }.tag(0).listStyle(.inset)
                    List(report.topFiveGalaxies) { target in
                        NavigationLink(destination: DetailView(target: target).environmentObject(location)) {
                            Text(target.name.first!)
                        }
                    }.tag(1).listStyle(.inset)
                    List(report.topFiveStarClusters) { target in
                        NavigationLink(destination: DetailView(target: target).environmentObject(location)) {
                            Text(target.name.first!)
                        }
                    }.tag(2).listStyle(.inset)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .scrollDisabled(true)
            } else {
                ProgressView()
            }
        }
    }
}

//struct DailyReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyReportView()
//    }
//}

