//
//  SettingsView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/13/22.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query var targetSettings: [TargetSettings]
    @Query var reportSettings: [ReportSettings]
    @State var tabSelection = 0

    var body: some View {
        NavigationStack {
            Form  {
                NavigationLink(destination: LocationSettings()) {
                    Label("Saved Locations", systemImage: "location")
                }
                NavigationLink(destination: GearSettings()) {
                    Label("Imaging Presets", systemImage: "camera.aperture")
                }
                NavigationLink(destination: AdvancedSettingsView(targetSettings: targetSettings.first!, reportSettings: reportSettings.first!)) {
                    Label("Advanced Settings", systemImage: "star")
                }
                NavigationLink(destination:  HiddenTargetsList()) {
                    Label("Hidden Targets", systemImage: "eye.slash")
                }
                NavigationLink(destination: AboutView()) {
                    Label("About", systemImage: "info.circle")
                }
//                Button("FOR PRERELEASE ONLY: Show/Hide Copyrighted Images") {
//                    DeepSkyTarget.overrideCopyright.toggle()
//                }
//                .buttonStyle(.bordered)
            }
            .toolbar {
                ToolbarLogo()
            }
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
