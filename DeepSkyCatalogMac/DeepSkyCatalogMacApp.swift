//
//  DeepSkyCatalogMacApp.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/4/23.
//

import SwiftUI

@main
struct DeepSkyCatalogMacApp: App {
    @StateObject private var persistenceManager = PersistenceManager.shared
    @ObservedObject private var networkManager = NetworkManager.shared
    @ObservedObject private var locationManager = LocationManager()
    var body: some Scene {
        WindowGroup {
            Mac_HomeView()
                .environment(\.managedObjectContext, persistenceManager.container.viewContext)
                .environmentObject(networkManager)
                .environmentObject(locationManager)
        }
        .commands {
            Menus()
        }
        
        WindowGroup(id: "settings") {
            Mac_SettingsView()
                .environment(\.managedObjectContext, persistenceManager.container.viewContext)
                .environmentObject(networkManager)
                .environmentObject(locationManager)
        }
        
        Window("About", id: "about") {
            Mac_AboutView()
        }
    }
}
