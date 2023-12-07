//
//  Mac_TargetSettings.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import SwiftUI
import SwiftData

struct Mac_TargetSettingsView: View {
    @Environment(\.modelContext) var context
    @Bindable var targetSettings: TargetSettings
    @State var isLimitingAltitudeModal: Bool = false
    
    var body: some View {
        Form {
            Toggle("Hide Targets that Never Rise", isOn: $targetSettings.hideNeverRises)
            TextField("Lowest acceptable altitude to image", value: $targetSettings.limitingAltitude, format: .number)
        }
        .formStyle(.grouped)
        .navigationTitle("Target Settings")
    }
}
