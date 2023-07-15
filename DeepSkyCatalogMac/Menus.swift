//
//  Menus.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import Foundation
import SwiftUI

struct Menus: Commands {
    @Environment(\.openWindow) var openWindow
    var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("Settings") {
                openWindow(id: "settings")
            }
        }
        CommandGroup(replacing: .appInfo) {
            Button("About Astrophotography Planner") {
                openWindow(id: "about")
            }
        }
    }
}
