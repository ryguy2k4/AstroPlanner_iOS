//
//  DeepSkyCatalogApp.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/13/22.
//

import SwiftUI
import CoreData

@main
struct DeepSkyCatalogApp: App {
    @StateObject private var persistenceController = PersistenceManager.shared
    @ObservedObject private var networkManager = NetworkManager.shared
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(networkManager)
        }
    }
}
