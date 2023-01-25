//
//  TargetSettings.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/24/23.
//

import SwiftUI
import CoreData

struct TargetSettings: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var settings: ReportSettings
    @State var isLimitingAltitudeModal: Bool = false
    
    init() {
        self.settings = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<ReportSettings>(entityName: "ReportSettings")).first!
    }
    
    var body: some View {
        Form {
            ConfigSection(header: "Target Settings") {
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
    }
}

//struct TargetSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        TargetSettings()
//    }
//}
