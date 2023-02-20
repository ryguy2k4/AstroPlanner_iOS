//
//  SettingsView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/13/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.date) var date
    @State var tabSelection = 0

    var body: some View {
        NavigationStack {
            Form  {
                NavigationLink(destination: LocationSettings()) {
                    Label("Locations", systemImage: "location")
                }
                NavigationLink(destination: GearSettings()) {
                    Label("Imaging Presets", systemImage: "camera.aperture")
                }
                NavigationLink(destination: TargetSettingsView()) {
                    Label("Target Settings", systemImage: "star")
                }
                NavigationLink(destination:  HiddenTargetsList()) {
                    Label("Hidden Targets", systemImage: "eye.slash")
                }
                NavigationLink(destination: AboutView()) {
                    Label("About", systemImage: "info.circle")
                }
                
//                ConfigSection(header: "Glossary") {
//                    NavigationLink(destination: MessierInfo()) {
//                        Label("Messier", systemImage: "m.circle")
//                    }
//                    NavigationLink(destination: CaldwellInfo()) {
//                        Label("Caldwell", systemImage: "c.circle")
//                    }
//                    NavigationLink(destination: SharplessInfo()) {
//                        Label("Sharpless", systemImage: "s.circle")
//                    }
//                }
            }
            .toolbar {
                ToolbarLogo()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct LabeledTextField: View {
    @Binding var text: String
    var label: String
    var prompt: String?
    var keyboardType: UIKeyboardType = .numbersAndPunctuation
    var body: some View {
        HStack {
            Text(label)
                .font(.callout)
            TextField(prompt ?? "", text: $text)
                .keyboardType(keyboardType)
        }
    }
}
