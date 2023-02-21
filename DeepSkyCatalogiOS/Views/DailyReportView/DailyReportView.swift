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
    @State var report: DailyReport?
    @State var internet: Bool = true
    @State var isSettingsModal = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header Section
                ReportHeader()
                
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
            .sheet(isPresented: $isSettingsModal) {
                DailyReportSettings(date: $date)
                    .presentationDetents([.fraction(0.4), .fraction(0.6), .fraction(0.8)])
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
