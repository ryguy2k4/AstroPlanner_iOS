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
    
    // location -> date -> sundata -> viewinginterval
    
    var body: some View {
        TabView {
            if let location: Location = {
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
            }() {
                HomeViewWithLocation(location: location)
            } else {
                NoLocationsView()
                    .tabItem {
                        Label("Daily Report", systemImage: "doc.text")
                    }
            }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct HomeViewWithLocation: View {
    @EnvironmentObject var networkManager: NetworkManager
    
    let location: Location
    @State var date: Date
    @State var internet = true
    @State var sunData: SunData? = nil
    
    init(location: Location) {
        self.location = location
        self._date = State(initialValue: .now.startOfLocalDay(timezone: location.timezone))
    }
    var body: some View {
        if let sunData = sunData {
            HomeViewWithSunData(location: location, date: $date, sunData: sunData)
                .onChange(of: date) { _ in
                    self.sunData = networkManager.sun[NetworkManager.DataKey(date: date, location: location)]
                }
        } else {
            if internet {
                DailyReportLoadingView(internet: $internet)
                    .task {
                        do {
                            try await networkManager.updateSunData(at: location, on: date)
                            sunData = networkManager.sun[NetworkManager.DataKey(date: date, location: location)]
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
        }
    }
}

struct HomeViewWithSunData: View {
    let location: Location
    @Binding var date: Date
    let sunData: SunData
    @State var viewingInterval: DateInterval
    
    init(location: Location, date: Binding<Date>, sunData: SunData) {
        self.location = location
        self._date = date
        self.sunData = sunData
        self._viewingInterval =  State(initialValue: sunData.ATInterval)
    }
    var body: some View {
        DailyReportView(date: $date, viewingInterval: $viewingInterval)
            .tabItem {
                Label("Daily Report", systemImage: "doc.text")
            }
            .environment(\.location, location)
            .environment(\.sunData, sunData)
        CatalogView(date: $date, viewingInterval: $viewingInterval)
            .tabItem {
                Label("Master Catalog", systemImage: "tray.full.fill")
            }
            .environment(\.location, location)
            .environment(\.sunData, sunData)
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//            .environment(\.managedObjectContext, PersistenceManager.shared.container.viewContext)
//            .environmentObject(NetworkManager.shared)
//    }
//}
