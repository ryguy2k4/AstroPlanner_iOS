//
//  TargetSettings.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/24/23.
//

import SwiftUI
import CoreData

struct TargetSettingsView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var settings: TargetSettings
    @State var isLimitingAltitudeModal: Bool = false
    
    init() {
        self.settings = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<TargetSettings>(entityName: "TargetSettings")).first!
    }
    
    var body: some View {
        Form {
            Toggle("Hide Targets that Never Rise", isOn: $settings.hideNeverRises)
            Button {
                isLimitingAltitudeModal = true
            } label: {
                HStack(spacing: 0) {
                    Text("Lowest acceptable altitude to image: ")
                        .foregroundColor(.primary)
                    Text(settings.limitingAltitude.formatted(.number.precision(.significantDigits(0...5))) + "°")
                }
            }
        }
        .sheet(isPresented: $isLimitingAltitudeModal) {
            Form {
                ConfigSection(footer: "The visibility score will be calculated as the percentage of the night that the target is above this altitude. This setting will effect the visibility scores shown in the master catalog too.") {
                    NumberPicker(num: $settings.limitingAltitude, placeValues: [.tens, .ones])
                }
            }
            .presentationDetents([.fraction(0.6)])
        }
        .onDisappear() {
            PersistenceManager.shared.saveData(context: context)
        }
        .navigationTitle("Target Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct TargetSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        TargetSettings()
//    }
//}
