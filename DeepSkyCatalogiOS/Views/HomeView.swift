//
//  HomeView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/2/22.
//

import SwiftUI
import CoreData
import CoreLocation

class HomeViewModel: ObservableObject {
    @Published var location: Location = .default
    @Published var date: Date = .now
    @Published var sunData: SunData = .default
    @Published var viewingInterval: DateInterval = .init(start: .now, duration: .pi)
}
struct HomeView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse), SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: FetchedResults<SavedLocation>
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    
    @State var internet = true
    @StateObject var vm: HomeViewModel = HomeViewModel()
    
    var body: some View {
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
                else {
                    // if available location but sunData and viewingInterval are being populated, then show a loading view
                    if internet {
                        DailyReportLoadingView(internet: $internet)
                            .tabItem {
                                Label("Daily Report", systemImage: "doc.text")
                            }
                            .environmentObject(vm)
                    }
                    // if available location but sunData and viewingInterval failed to populate, then show an error screen
                    else {
                        DailyReportLoadingFailedView(internet: $internet)
                            .tabItem {
                                Label("Daily Report", systemImage: "doc.text")
                            }
                            .environmentObject(vm)
                    }
                    // Append BasicCatalogView to the tab bar when sunData and viewingInterval are not populated
                    BasicCatalogView()
                        .tabItem {
                            Label("Master Catalog", systemImage: "tray.full.fill")
                        }
                        .environmentObject(vm)
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
                vm.date = .now.startOfLocalDay(timezone: newLocation.timezone)
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
        
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//            .environment(\.managedObjectContext, PersistenceManager.shared.container.viewContext)
//            .environmentObject(NetworkManager.shared)
//    }
//}
