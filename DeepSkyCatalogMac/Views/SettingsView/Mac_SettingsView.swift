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
            Mac_GearSettings()
                .tabItem {
                    Label("Imaging Presets", systemImage: "camera.aperture")
                }
            Mac_TargetSettingsView()
                .tabItem {
                    Label("Target Settings", systemImage: "star")
                }
            Mac_HiddenTargetsList()
                .tabItem {
                    Label("Hidden Targets", systemImage: "eye.slash")
                }
                .navigationTitle("Saved Locations")
        }
    }
}
