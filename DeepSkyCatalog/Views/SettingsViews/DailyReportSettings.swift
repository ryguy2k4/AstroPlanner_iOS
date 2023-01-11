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
    @State var isMinFOVCoverageModal: Bool = false
    @State var isMinVisibilityModal: Bool = false

    init() {
        self.settings = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<ReportSettings>(entityName: "ReportSettings")).first!
    }
    
    var body: some View {
        Form {
            ConfigSection(header: "Daily Report") {
                Toggle("Prefer broadband targets on moonless nights", isOn: $settings.preferBroadband)
                Button {
                    isMoonPercentModal = true
                } label: {
                    HStack(spacing: 0) {
                        Text("Max Allowed Moon for Broadband: ")
                            .foregroundColor(.primary)
                        Text(settings.maxAllowedMoon.percent())
                    }
                }
                Button {
                    isMinFOVCoverageModal = true
                } label: {
                    HStack(spacing: 0) {
                        Text("Minimum FOV Coverage: ")
                            .foregroundColor(.primary)
                        Text(settings.minFOVCoverage.percent())
                    }
                }
                Button {
                    isMinVisibilityModal = true
                } label: {
                    HStack(spacing: 0) {
                        Text("Minimum Visibility: ")
                            .foregroundColor(.primary)
                        Text(settings.minVisibility.percent())
                    }
                    
                }
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
        .sheet(isPresented: $isMoonPercentModal) {
            Form {
                ConfigSection(footer: "If the moon illumination is greater than this value, then broadband targets will not be suggested. Set to 99% to never exclude broadband targets.") {
                    NumberPicker(num: $settings.maxAllowedMoon, placeValues: [.tenths, .hundredths])
                }
            }
            .presentationDetents([.fraction(0.6)])
        }
        .sheet(isPresented: $isMinFOVCoverageModal) {
            Form {
                ConfigSection(footer: "This is the minimum ratio between your scope's FOV length and the target's arc length. Should probably be around 25%") {
                    NumberPicker(num: $settings.minFOVCoverage, placeValues: [.tenths, .hundredths])
                }
            }
            .presentationDetents([.fraction(0.6)])
        }
        .sheet(isPresented: $isMinVisibilityModal) {
            Form {
                ConfigSection(footer: "Targets shown in the daily report must be visible for at least this percentage of the night.") {
                    NumberPicker(num: $settings.minVisibility, placeValues: [.tenths, .hundredths])
                }
            }
            .presentationDetents([.fraction(0.6)])
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

//struct DailyReportSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyReportSettings()
//    }
//}
