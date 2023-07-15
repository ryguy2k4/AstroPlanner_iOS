//
//  Mac_TargetSettings.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import SwiftUI

struct Mac_TargetSettingsView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var settings: TargetSettings
    @State var isLimitingAltitudeModal: Bool = false
    
    init() {
        self.settings = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<TargetSettings>(entityName: "TargetSettings")).first!
    }
    
    var body: some View {
        Form {
            Toggle("Hide Targets that Never Rise", isOn: $settings.hideNeverRises)
            TextField("Lowest acceptable altitude to image", value: $settings.limitingAltitude, format: .number)
        }
        .onDisappear() {
            PersistenceManager.shared.saveData(context: context)
        }
        .formStyle(.grouped)
        .navigationTitle("Target Settings")
    }
}
