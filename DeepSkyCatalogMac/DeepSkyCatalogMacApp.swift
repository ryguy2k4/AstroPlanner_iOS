//
//  DeepSkyCatalogMacApp.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/4/23.
//

import SwiftUI

@main
struct DeepSkyCatalogMacApp: App {
    let persistenceManager = PersistenceManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceManager.container.viewContext)
        }
    }
}
