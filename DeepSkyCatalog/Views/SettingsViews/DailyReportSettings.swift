//
//  DailyReportSettings.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/21/22.
//

import SwiftUI
import CoreData

struct DailyReportSettings: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var settings: ReportSettings
//    @State var isMagModal: Bool = false
    @State var isMoonPercentModal: Bool = false
    @State var isLimitingAltitudeModal: Bool = false

    init() {
        self.settings = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<ReportSettings>(entityName: "ReportSettings")).first!
    }
    
    var body: some View {
        Form {
            ConfigSection(header: "Daily Report") {
                Toggle("Prefer broadband targets on moonless nights", isOn: $settings.preferBroadband)
                Button("Max Allowed Moon for Broadband: \(settings.maxAllowedMoon.percent())", action: { isMoonPercentModal = true })
                Button("Lowest acceptable altitude to image: \(settings.limitingAltitude.formatted(.number.precision(.significantDigits(0...5))))°", action: { isLimitingAltitudeModal = true })
                //Button("Magnitude: \(settings.brightestMag.formatted()) to \(settings.dimmestMag.formatted())", action: { isMagModal = true })
            }
        }
//        .sheet(isPresented: $isMagModal) {
//            MinMaxPicker(min: $settings.brightestMag, max: $settings.dimmestMag, maxTitle: "Brighter than", minTitle: "Dimmer than", placeValues: [.ones, .tenths])
//                .presentationDetents([.fraction(0.8)])
//        }
        .sheet(isPresented: $isMoonPercentModal) {
            Form {
                NumberPicker(num: $settings.maxAllowedMoon, placeValues: [.tenths, .hundredths])
            }
            .presentationDetents([.fraction(0.8)])
        }
        .sheet(isPresented: $isLimitingAltitudeModal) {
            Form {
                NumberPicker(num: $settings.limitingAltitude, placeValues: [.tens, .ones])
            }
            .presentationDetents([.fraction(0.8)])
        }
        .onDisappear() {
            PersistenceManager.shared.saveData(context: context)
        }
    }
}

//struct DailyReportSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyReportSettings()
//    }
//}
