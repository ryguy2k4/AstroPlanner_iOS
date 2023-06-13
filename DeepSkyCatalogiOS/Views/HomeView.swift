//
//  HomeView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/2/22.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse), SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: FetchedResults<SavedLocation>
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @FetchRequest(sortDescriptors: []) var targetSettings: FetchedResults<TargetSettings>
    
    @State var internet = true
    
    @State var location: Location? = nil
    @State var date: Date = .now
    @State var sunData: SunData? = nil
    @State var viewingInterval: DateInterval? = nil
    
    var body: some View {
        TabView {
            if let location = location {
                if let sunData = sunData, let viewingInterval = Binding($viewingInterval) {
                    DailyReportView(date: $date, viewingInterval: viewingInterval)
                        .tabItem {
                            Label("Daily Report", systemImage: "doc.text")
                        }
                        .environment(\.location, location)
                        .environment(\.sunData, sunData)
                    CatalogView(date: $date, viewingInterval: viewingInterval)
                        .tabItem {
                            Label("Master Catalog", systemImage: "tray.full.fill")
                        }
                        .environment(\.location, location)
                        .environment(\.sunData, sunData)
                } else {
                    if internet {
                        DailyReportLoadingView(internet: $internet)
                            .task {
                                do {
                                    let data = try await networkManager.updateSunData(at: location, on: $date.wrappedValue)
                                    // merge the new data, overwriting if necessary
                                    networkManager.sun.merge(data) { _, new in new }
                                    sunData = networkManager.sun[NetworkManager.DataKey(date: $date.wrappedValue, location: location)]
                                    // here insert check for requesting data between midnight and night end should get info for the previous day still
                                    viewingInterval = sunData?.ATInterval
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
                    BasicCatalogView(date: $date)
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
                        self.location = {
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
                        if let location = location {
                            date = .now.startOfLocalDay(timezone: location.timezone)
                        }
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
            if let newLocation = newLocation, newLocation != self.location {
                self.location = newLocation
                self.date = .now.startOfLocalDay(timezone: newLocation.timezone)
            }
        }
        .onChange(of: date) { newDate in
            print("Date Change -> ", newDate)
            sunData = nil
        }
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
