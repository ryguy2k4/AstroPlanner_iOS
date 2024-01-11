//
//  Mac_HomeView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/4/23.
//

import SwiftUI
import SwiftData

/**
 This struct contains the 4 variables that control the state of the app
 The entire app refers back to a single instance of this struct as the source of these values
 */
class HomeViewModel: ObservableObject {
    @Published var location: Location = .default
    @Published var date: Date = .now
    @Published var sunData: SunData = .default
    @Published var viewingInterval: DateInterval = .init(start: .now, duration: .pi)
}

struct Mac_HomeView: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: [SavedLocation]
    @Query var reportSettings: [ReportSettings]
    @Query var targetSettings: [TargetSettings]
    
    @StateObject var vm: HomeViewModel = HomeViewModel()
    
    enum SidebarItem: String, Identifiable, CaseIterable {
        var id: Self { self }
        case report = "Daily Report"
        case catalog = "Master Catalog"
        case journal = "Journal"
        case curator = "Curator"
        
        var icon: String {
            switch self {
            case .report: return "doc.text"
            case .catalog: return "tray.full.fill"
            case .journal: return "doc.richtext"
            case .curator: return "sparkles"
            }
        }
        
        static var enabledViews: [Self] {
            #if DEBUG
            return Self.allCases
            #else
            return [.report, .catalog, .journal]
            #endif
        }
    }
    
    @State var sidebarVisibility: NavigationSplitViewVisibility = .automatic
    @State var sidebarItem: SidebarItem = .report
    
    
    var body: some View {
        NavigationSplitView(columnVisibility: $sidebarVisibility) {
            List(SidebarItem.enabledViews, selection: $sidebarItem) { item in
                Label(item.rawValue, systemImage: item.icon)
            }
        } detail: {
            // If a valid location is selected
            if vm.location != .default {
                // If sunData and viewingInterval are valid, append DailyReportView and CatalogView to the tab bar
                if vm.sunData != .default && vm.viewingInterval.duration != .pi {
                    switch sidebarItem {
                    case .report:
                        Mac_DailyReportView()
                            .environmentObject(vm)
                    case .catalog:
                        Mac_CatalogView()
                            .environmentObject(vm)
                    case .journal:
                        Mac_JournalView()
                    case .curator:
                        TargetCuratorView()
                    }
                }
                // If sunData and viewingInterval are not valid, show a loading view while sunData is being calculated
                else {
                    switch sidebarItem {
                    case .report:
                        DailyReportLoadingView()
                            .environmentObject(vm)
                    case .catalog:
                        Text("Basic Catalog View")
                    case .journal:
                        Mac_JournalView()
                    case .curator:
                        EmptyView()
                    }
                }
            } else {
                // if no location available, prompt user for location
                Text("No Locations View: Prompt for Location")
            }
        }
        .onReceive(locationList.publisher) { _ in
            let newLocation: Location? = {
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
            if let newLocation = newLocation, newLocation != vm.location {
                vm.location = newLocation
                vm.date = .now.startOfLocalDay(timezone: newLocation.timezone)
            }
        }
        .onReceive(vm.$date) { _ in
            vm.sunData = .default
        }
        .onAppear {
            // set default report settings for first time launch
            if reportSettings.isEmpty {
                let defaultSettings = ReportSettings()
                context.insert(defaultSettings)
            }
            // set default report settings for first time launch
            if targetSettings.isEmpty {
                let defaultSettings = TargetSettings()
                context.insert(defaultSettings)
            }
        }
    }
}

struct DailyReportLoadingView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var store: HomeViewModel
    @Query var reportSettings: [ReportSettings]
    var body: some View {
        NavigationStack {
            VStack {
                ProgressView("Fetching Sun Data")
                    .padding(.top, 50)
                Spacer()
            }
            .task {
                store.sunData = Sun.sol.getNextInterval(location: store.location, date: store.date)
                // here insert check for requesting data between midnight and night end should get info for the previous day still
                if reportSettings.first!.darknessThreshold == 2 {
                    store.viewingInterval = store.sunData.CTInterval
                } else if reportSettings.first!.darknessThreshold == 1 {
                    store.viewingInterval = store.sunData.NTInterval
                } else {
                    store.viewingInterval = store.sunData.ATInterval
                }
            }
        }
    }
}
