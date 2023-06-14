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
    @Published var location: Location = Location(current: CLLocation(latitude: 0, longitude: 0))
    @Published var date: Date = .now
    @Published var sunData: SunData = SunData()
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
            if let location = vm.location {
                if let _ = vm.sunData, let _ = Binding($vm.viewingInterval) {
                    DailyReportView()
                        .environmentObject(vm)
                        .tabItem {
                            Label("Daily Report", systemImage: "doc.text")
                        }
                    CatalogView()
                        .environmentObject(vm)
                        .tabItem {
                            Label("Master Catalog", systemImage: "tray.full.fill")
                        }
                } else {
                    if internet {
                        DailyReportLoadingView(internet: $internet)
                            .task {
                                do {
                                    let data = try await networkManager.updateSunData(at: location, on: $vm.date.wrappedValue)
                                    // merge the new data, overwriting if necessary
                                    networkManager.sun.merge(data) { _, new in new }
                                    vm.sunData = networkManager.sun[NetworkManager.DataKey(date: $vm.date.wrappedValue, location: location)] ?? SunData()
                                    // here insert check for requesting data between midnight and night end should get info for the previous day still
                                    vm.viewingInterval = vm.sunData.ATInterval
                                } catch {
                                    internet = false
                                }
                            }
                            .tabItem {
                                Label("Daily Report", systemImage: "doc.text")
                            }
                    } else {
                        DailyReportLoadingFailedView(internet: $internet)
                            .tabItem {
                                Label("Daily Report", systemImage: "doc.text")
                            }
                    }
                    BasicCatalogView(date: $vm.date)
                        .tabItem {
                            Label("Master Catalog", systemImage: "tray.full.fill")
                        }
                        .environment(\.location, location)
                }
            } else {
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
                        //                        if let location = vm.location {
                        vm.date = .now.startOfLocalDay(timezone: vm.location.timezone)
                        //                        }
                    }
            }
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
            print("Date Change -> ", newValue)
            vm.sunData = .init()
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
