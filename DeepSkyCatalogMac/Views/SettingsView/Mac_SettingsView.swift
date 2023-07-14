//
//  Mac_SettingsView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import SwiftUI

struct Mac_SettingsView: View {
    var body: some View {
        TabView {
            Mac_LocationSettings()
                .tabItem {
                    Label("Saved Locations", systemImage: "location")
                }
                .navigationTitle("Saved Locations")
            Text("Imaging Presets")
                .tabItem {
                    Label("Imaging Presets", systemImage: "camera.aperture")
                }
                .navigationTitle("Imaging Presets")
            Text("Target Settings")
                .tabItem {
                    Label("Target Settings", systemImage: "star")
                }
                .navigationTitle("Target Settings")
            Text("Hidden Targets")
                .tabItem {
                    Label("Hidden Targets", systemImage: "eye.slash")
                }
                .navigationTitle("Saved Locations")
        }
    }
}
