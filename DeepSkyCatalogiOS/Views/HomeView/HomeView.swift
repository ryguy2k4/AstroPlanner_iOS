//
//  HomeView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/2/22.
//

import SwiftUI
import SwiftData
import DeepSkyCore

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

struct HomeView: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject var locationManager: LocationManager
    
    // Fetch data stored in persistence
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: [SavedLocation]
    @Query var reportSettings: [ReportSettings]
    @Query var targetSettings: [TargetSettings]
    @Query var hiddenTargets: [HiddenTarget]
    
    // Create an instance of HomeViewModel that manages the state of the app
    @StateObject var store: HomeViewModel = HomeViewModel()
    
    var body: some View {
        TabView {
            // if settings are initialized
            if !reportSettings.isEmpty && !targetSettings.isEmpty {
                // If a valid location is selected
                if store.location != .default {
                    // If sunData and viewingInterval are valid, append DailyReportView and CatalogView to the tab bar
                    if store.sunData != .default && store.viewingInterval.duration != .pi {
                        DailyReportView()
                            .environmentObject(store)
                            .tabItem {
                                Label("Daily Report", systemImage: "doc.text")
                            }
                        CatalogView()
                            .environmentObject(store)
                            .tabItem {
                                Label("Master Catalog", systemImage: "tray.full.fill")
                            }
                    }
                    // If sunData and viewingInterval are not valid, show a loading view while sunData is being calculated
                    else {
                        DailyReportLoadingView()
                            .environmentObject(store)
                            .tabItem {
                                Label("Daily Report", systemImage: "doc.text")
                            }
                        CatalogLoadingView()
                            .tabItem {
                                Label("Master Catalog", systemImage: "tray.full.fill")
                            }
                    }
                }
                // If no location is available, prompt the user for a location
                else {
                    // Append NoLocationsView to the tab bar in place of both Daily Report and Master Catalog
                    NoLocationsView()
                        .environmentObject(store)
                        .tabItem {
                            Label("Daily Report", systemImage: "doc.text")
                        }
                    NoLocationsView()
                        .environmentObject(store)
                        .tabItem {
                            Label("Master Catalog", systemImage: "tray.full.fill")
                        }
                }
                // Append SettingsView to the tab bar of every permutation
                SettingsView()
                    .environmentObject(store)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
        }
        // If the saved location list changes, reselect the active location
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
            if let newLocation = newLocation, newLocation != store.location {
                store.location = newLocation
                store.date = store.date.startOfLocalDay(timezone: newLocation.timezone)
            }
        }
        // If the date changes, invalidate the current sunData
        .onReceive(store.$date) { _ in
            store.sunData = .default
        }
        .onAppear {
            // correct the transparency bug for Tab bars
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
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
