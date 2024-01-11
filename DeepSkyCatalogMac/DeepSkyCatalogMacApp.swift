//
//  DeepSkyCatalogMacApp.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/4/23.
//

import SwiftUI
import SwiftData

@main
struct DeepSkyCatalogMacApp: App {
    @ObservedObject private var networkManager = NetworkManager.shared
    @ObservedObject private var locationManager = LocationManager()
    let modelContainer: ModelContainer
    
    // Initialize Persistence Container
    init() {
        do {
            modelContainer = try ModelContainer(for: ImagingPreset.self, TargetSettings.self, HiddenTarget.self, ReportSettings.self, SavedLocation.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Mac_HomeView()
                .environmentObject(networkManager)
                .environmentObject(locationManager)
                .frame(minWidth: 600, maxWidth: 2400, minHeight: 400,  maxHeight: 1600)
        }
        .commands {
            Menus()
        }
        .modelContainer(modelContainer)
        
        WindowGroup(id: "settings") {
            Mac_SettingsView()
                .environmentObject(networkManager)
                .environmentObject(locationManager)
                .frame(minWidth: 400, maxWidth: 500, minHeight: 600,  maxHeight: 1200)
        }
        .modelContainer(modelContainer)
        
        Window("About", id: "about") {
            Mac_AboutView()
        }
        .modelContainer(modelContainer)
    }
}
