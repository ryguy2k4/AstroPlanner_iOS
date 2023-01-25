//
//  SettingsView.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/13/22.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.date) var date
    @State var tabSelection = 0

    var body: some View {
        NavigationStack {
            Form  {
                
                ConfigSection(header: "Settings") {
                    NavigationLink(destination: LocationSettings()) {
                        Label("Location", systemImage: "location")
                    }
                    NavigationLink(destination: GearSettings()) {
                        Label("Imaging Presets", systemImage: "camera.aperture")
                    }
                    NavigationLink(destination: DailyReportSettings()) {
                        Label("Report Settings", systemImage: "doc.text")
                    }
//                    NavigationLink(destination: TargetSettings()) {
//                        Label("Target Settings", systemImage: "star")
//                    }
                }
                
                ConfigSection(header: "Catalogs") {
                    NavigationLink(destination: MessierInfo()) {
                        Label("Messier", systemImage: "m.circle")
                    }
                    NavigationLink(destination: CaldwellInfo()) {
                        Label("Caldwell", systemImage: "c.circle")
                    }
                    NavigationLink(destination: SharplessInfo()) {
                        Label("Sharpless", systemImage: "s.circle")
                    }
                }
                
                ConfigSection {
                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.circle")
                    }
                }
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
