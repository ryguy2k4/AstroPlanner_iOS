//
//  DeepSkyCatalogMacApp.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/4/23.
//

import SwiftUI

@main
struct DeepSkyCatalogMacApp: App {
    @ObservedObject private var networkManager = NetworkManager.shared
    @ObservedObject private var locationManager = LocationManager()
    var body: some Scene {
        WindowGroup {
            Mac_HomeView()
                .environmentObject(networkManager)
                .environmentObject(locationManager)
        }
        .commands {
            Menus()
        }
        .modelContainer(for: [ImagingPreset.self, TargetSettings.self, HiddenTarget.self, ReportSettings.self, SavedLocation.self])
        
        WindowGroup(id: "settings") {
            Mac_SettingsView()
                .environment(\.managedObjectContext, persistenceManager.container.viewContext)
                .environmentObject(networkManager)
                .environmentObject(locationManager)
        }
        .modelContainer(for: [ImagingPreset.self, TargetSettings.self, HiddenTarget.self, ReportSettings.self, SavedLocation.self])
        
        Window("About", id: "about") {
            Mac_AboutView()
        }
        .modelContainer(for: [ImagingPreset.self, TargetSettings.self, HiddenTarget.self, ReportSettings.self, SavedLocation.self])
    }
}
