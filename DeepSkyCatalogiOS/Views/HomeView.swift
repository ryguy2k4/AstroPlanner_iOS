//
//  HomeView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/2/22.
//

import SwiftUI
import SwiftData
import CoreLocation

class HomeViewModel: ObservableObject {
    @Published var location: Location = .default
    @Published var date: Date = .now
    @Published var sunData: SunData = .default
    @Published var viewingInterval: DateInterval = .init(start: .now, duration: .pi)
}
struct HomeView: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: [SavedLocation]
    @Query var reportSettings: [ReportSettings]
    @Query var targetSettings: [TargetSettings]
    
    @StateObject var vm: HomeViewModel = HomeViewModel()
    
    var body: some View {
        if !reportSettings.isEmpty || !targetSettings.isEmpty {
            TabView {
                if vm.location != .default {
                    // if available location and sunData and viewingInterval populated then show DailyReportView, CatalogView
                    if vm.sunData != .default && vm.viewingInterval.duration != .pi {
                        DailyReportView()
                            .tabItem {
                                Label("Daily Report", systemImage: "doc.text")
                            }
                            .environmentObject(vm)
                        CatalogView()
                            .tabItem {
                                Label("Master Catalog", systemImage: "tray.full.fill")
                            }
                            .environmentObject(vm)
                    }
                    // show a loading view while sun data is being calculated
                    else {
                        DailyReportLoadingView()
                            .tabItem {
                                Label("Daily Report", systemImage: "doc.text")
                            }
                            .environmentObject(vm)
                        CatalogLoadingView()
                            .tabItem {
                                Label("Master Catalog", systemImage: "tray.full.fill")
                            }
                    }
                }
                // if no location available, prompt user for location
                else {
                    NoLocationsView()
                        .tabItem {
                            Label("Daily Report", systemImage: "doc.text")
                        }
                        .onAppear() {
                            vm.location = {
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
                                }
                                else {
                                    // no location found
                                    return Location(current: CLLocation(latitude: 0, longitude: 0))
                                }
                            }()
                            vm.date = .now.startOfLocalDay(timezone: vm.location.timezone)
                        }
                        .environmentObject(locationManager)
                        .environmentObject(vm)
                    NoLocationsView()
                        .tabItem {
                            Label("Master Catalog", systemImage: "tray.full.fill")
                        }
                }
                // Append SettingsView to the tab bar of every permutation
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
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
                    vm.date = vm.date.startOfLocalDay(timezone: newLocation.timezone)
                }
            }
            .onReceive(vm.$date, perform: { newValue in
                //print("Date Change -> ", newValue)
                vm.sunData = .default
            })
            .onAppear {
                // correct the transparency bug for Tab bars
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        } else {
            // set default report settings
            if reportSettings.isEmpty {
                ProgressView("")
                    .task {
                        let defaultSettings = ReportSettings()
                        context.insert(defaultSettings)
                    }
            }
            if targetSettings.isEmpty {
                ProgressView("")
                    .task {
                        let defaultSettings = TargetSettings()
                        context.insert(defaultSettings)
                    }
            }
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//            .environment(\.managedObjectContext, PersistenceManager.shared.container.viewContext)
//            .environmentObject(NetworkManager.shared)
//    }
//}
