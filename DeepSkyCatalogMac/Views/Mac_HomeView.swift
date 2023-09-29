//
//  Mac_HomeView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/4/23.
//

import SwiftUI
import CoreData

class HomeViewModel: ObservableObject {
    @Published var location: Location = .default
    @Published var date: Date = .now
    @Published var sunData: SunData = .default
    @Published var viewingInterval: DateInterval = .init(start: .now, duration: .pi)
}

struct Mac_HomeView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse), SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: FetchedResults<SavedLocation>
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    
    @State var internet = true
    @StateObject var vm: HomeViewModel = HomeViewModel()
    
    enum SidebarItem: String, Identifiable, CaseIterable {
        var id: Self { self }
        case report = "Daily Report"
        case catalog = "Master Catalog"
        
        var icon: String {
            switch self {
            case .report: return "doc.text"
            case .catalog: return "tray.full.fill"
            }
        }
    }
    
    @State var sidebarVisibility: NavigationSplitViewVisibility = .automatic
    @State var sidebarItem: SidebarItem = .report
    
    
    var body: some View {
        NavigationSplitView(columnVisibility: $sidebarVisibility) {
            List(SidebarItem.allCases, selection: $sidebarItem) { item in
                Label(item.rawValue, systemImage: item.icon)
            }
        } detail: {
            if vm.location != .default {
                // if available location and sunData and viewingInterval populated then show DailyReportView, CatalogView
                if vm.sunData != .default && vm.viewingInterval.duration != .pi {
                    switch sidebarItem {
                    case .report:
                        Mac_DailyReportView()
                            .environmentObject(vm)
                    case .catalog:
                        Mac_CatalogView()
                            .environmentObject(vm)
                    }
                } else {
                    // if available location but sunData and viewingInterval are being populated, then show a loading view
                    if internet {
                        switch sidebarItem {
                        case .report:
                            DailyReportLoadingView(internet: $internet)
                                .environmentObject(vm)
                        case .catalog:
                            Text("Basic Catalog View")
                        }
                    }
                    // if available location but sunData and viewingInterval failed to populate, then show an error screen
                    else {
                        switch sidebarItem {
                        case .report:
                            DailyReportLoadingFailedView(internet: $internet)
                                .environmentObject(vm)
                        case .catalog:
                            Text("Basic Catalog View")
                        }
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
        .onReceive(vm.$date, perform: { newValue in
            //print("Date Change -> ", newValue)
            vm.sunData = .default
        })
        .frame(minWidth: 600, maxWidth: 2400, minHeight: 400,  maxHeight: 1600)
    }
}

//struct Mac_HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        Mac_HomeView()
//    }
//}

struct DailyReportLoadingView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var store: HomeViewModel
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @Binding var internet: Bool
    var body: some View {
        NavigationStack {
            VStack {
                ProgressView("Fetching Sun Data")
                    .padding(.top, 50)
                Spacer()
            }
            .task {
                do {
                    store.sunData = Sun.sol.getNextInterval(location: store.location, date: store.date)
                    // here insert check for requesting data between midnight and night end should get info for the previous day still
                    if reportSettings.first!.darknessThreshold == Int16(2) {
                        store.viewingInterval = store.sunData.CTInterval
                    } else if reportSettings.first!.darknessThreshold == Int16(1) {
                        store.viewingInterval = store.sunData.NTInterval
                    } else {
                        store.viewingInterval = store.sunData.ATInterval
                    }
                } catch {
                    internet = false
                }
            }
        }
    }
}

struct DailyReportLoadingFailedView: View {
    @EnvironmentObject var store: HomeViewModel
    @EnvironmentObject var networkManager: NetworkManager
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @Binding var internet: Bool
    var body: some View {
        NavigationStack {
            VStack {
                Text("Daily Report Unavailable Offline")
                    .fontWeight(.bold)
                    .padding(.vertical)
                Button("Retry") {
                    internet = true
                    Task {
                        do {
                            store.sunData = Sun.sol.getNextInterval(location: store.location, date: store.date)
                            if reportSettings.first!.darknessThreshold == Int16(2) {
                                store.viewingInterval = store.sunData.CTInterval
                            } else if reportSettings.first!.darknessThreshold == Int16(1) {
                                store.viewingInterval = store.sunData.NTInterval
                            } else {
                                store.viewingInterval = store.sunData.ATInterval
                            }
                        } catch {
                            internet = false
                        }
                    }
                }
                Spacer()
            }
        }
    }
}
