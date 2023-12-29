//
//  DeepSkyCatalogApp.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/13/22.
//

import SwiftUI
import SwiftData

@main
struct DeepSkyCatalogApp: App {
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
            HomeView()
                .environmentObject(locationManager)
        }
        .modelContainer(modelContainer)
    }
}
