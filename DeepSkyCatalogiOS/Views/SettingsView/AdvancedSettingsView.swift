//
//  TargetSettings.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/24/23.
//

import SwiftUI
import CoreData

struct AdvancedSettingsView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.isEnabled) var isEnabled
    @ObservedObject var targetSettings: TargetSettings
    @ObservedObject var reportSettings: ReportSettings
    @State var isLimitingAltitudeModal: Bool = false
    @State var isMoonPercentModal: Bool = false
    @State var isMinFOVCoverageModal: Bool = false
    @State var isMinVisibilityModal: Bool = false
    
    init() {
        self.targetSettings = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<TargetSettings>(entityName: "TargetSettings")).first!
        self.reportSettings = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<ReportSettings>(entityName: "ReportSettings")).first!
    }
    
    var body: some View {
        Form {
            ConfigSection(header: "Target Settings") {
                Toggle("Hide Targets that Never Rise", isOn: $targetSettings.hideNeverRises)
                Button {
                    isLimitingAltitudeModal = true
                } label: {
                    HStack(spacing: 0) {
                        Text("Lowest acceptable altitude to image: ")
                            .foregroundColor(.primary)
                        Text(targetSettings.limitingAltitude.formatted(.number.precision(.significantDigits(0...5))) + "°")
                    }
                }
            }
            ConfigSection(header: "Report Settings") {
                Button {
                    isMinFOVCoverageModal = true
                } label: {
                    HStack {
                        Text("Minimum FOV Coverage: ")
                            .foregroundColor(isEnabled ? .primary : .secondary)
                        Spacer()
                        Text(reportSettings.minFOVCoverage.percent())
                    }
                }
                Button {
                    isMinVisibilityModal = true
                } label: {
                    HStack {
                        Text("Minimum Visibility Score: ")
                            .foregroundColor(isEnabled ? .primary : .secondary)
                        Spacer()
                        Text(reportSettings.minVisibility.percent())
                    }
                    
                }
                
                Toggle("Filter For Moon Phase", isOn: $reportSettings.filterForMoonPhase)
                    .foregroundColor(isEnabled ? .primary : .secondary)
                
                Button {
                    isMoonPercentModal = true
                } label: {
                    HStack {
                        Text("Max Moon for Broadband: ")
                            .foregroundColor(reportSettings.filterForMoonPhase ? .primary : .secondary)
                            .foregroundColor(isEnabled ? .primary : .secondary)
                        Spacer()
                        Text(reportSettings.maxAllowedMoon.percent())
                    }
                    
                }
                .disabled(!reportSettings.filterForMoonPhase)
                
                Toggle("Prefer Broadband on Moonless Nights", isOn: $reportSettings.preferBroadband)
                    .foregroundColor(reportSettings.filterForMoonPhase ? .primary : .secondary)
                    .foregroundColor(isEnabled ? .primary : .secondary)
                    .disabled(!reportSettings.filterForMoonPhase)
            }
        }
        .sheet(isPresented: $isLimitingAltitudeModal) {
            Form {
                ConfigSection(footer: "The visibility score will be calculated as the percentage of the night that the target is above this altitude. This setting will effect the visibility scores shown in the master catalog too.") {
                    NumberPicker(num: $targetSettings.limitingAltitude, placeValues: [.tens, .ones])
                }
            }
            .presentationDetents([.fraction(0.6)])
        }
        .sheet(isPresented: $isMoonPercentModal) {
            Form {
                ConfigSection(footer: "If the moon illumination is greater than this value, then broadband targets will not be suggested.") {
                    NumberPicker(num: $reportSettings.maxAllowedMoon, placeValues: [.tenths, .hundredths])
                }
            }
            .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $isMinFOVCoverageModal) {
            Form {
                ConfigSection(footer: "This is the minimum ratio between your scope's FOV length and the target's arc length. Should probably be around 25%.") {
                    NumberPicker(num: $reportSettings.minFOVCoverage, placeValues: [.tenths, .hundredths])
                }
            }
            .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $isMinVisibilityModal) {
            Form {
                ConfigSection(footer: "Targets shown in the daily report must be visible for at least this percentage of the night.") {
                    NumberPicker(num: $reportSettings.minVisibility, placeValues: [.tenths, .hundredths])
                }
            }
            .presentationDetents([.fraction(0.4)])
        }
        .onDisappear() {
            PersistenceManager.shared.saveData(context: context)
        }
        .navigationTitle("Advanced Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct TargetSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        TargetSettings()
//    }
//}

