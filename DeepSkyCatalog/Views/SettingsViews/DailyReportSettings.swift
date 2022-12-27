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
    @State var isMagModal: Bool = false
    @State var isMoonPercentModal: Bool = false

    init() {
        self.settings = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<ReportSettings>(entityName: "ReportSettings")).first!
    }
    
    var body: some View {
        Form {
            ConfigSection(header: "Daily Report") {
                Toggle("Prefer broadband targets on moonless nights", isOn: $settings.preferBroadband)
                Button("Max Allowed Moon for Broadband: \(settings.maxAllowedMoon.percent())", action: { isMoonPercentModal = true })
                //Button("Magnitude: \(settings.brightestMag.formatted()) to \(settings.dimmestMag.formatted())", action: { isMagModal = true })
            }
        }
        .sheet(isPresented: $isMagModal) {
            MagnitudeFilter(min: $settings.brightestMag, max: $settings.dimmestMag)
                .presentationDetents([.fraction(0.8)])
        }
        .sheet(isPresented: $isMoonPercentModal) {
            Form {
                NumberPicker(num: $settings.maxAllowedMoon, placeValues: [.tenths, .hundredths])
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
