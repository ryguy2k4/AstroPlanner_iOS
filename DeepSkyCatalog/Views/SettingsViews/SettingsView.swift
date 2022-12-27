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
        NavigationView {
            Form  {
                ConfigSection(header: "Settings") {
                    NavigationLink(destination: LocationSettings()) {
                        Text("Location")
                    }
                    NavigationLink(destination: GearSettings()) {
                        Text("Imaging Presets")
                    }
                    NavigationLink(destination: DailyReportSettings()) {
                        Text("Report Settings")
                    }
                }
            }
        }
    }
}

struct SettingsField: View {
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
