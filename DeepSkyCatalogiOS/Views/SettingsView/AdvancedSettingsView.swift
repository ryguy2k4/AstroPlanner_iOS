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
            
            // Hide Targets that Never Rise
            Section {
                Toggle("Hide Targets that Never Rise", isOn: $targetSettings.hideNeverRises)
            } footer: {
                Text("Prevents targets that never rise at the selected location from appearing in the master catalog.")
            }
            
            // Limiting Altitude
            Section {
                Button {
                    isLimitingAltitudeModal = true
                } label: {
                    HStack(spacing: 0) {
                        Text("Lowest acceptable altitude to image: ")
                            .foregroundColor(.primary)
                        Text(targetSettings.limitingAltitude.formatted(.number.precision(.significantDigits(0...5))) + "°")
                    }
                }
            } footer: {
                Text("The visibility score will be calculated as the percentage of the night that the target is above this altitude. This setting will affect the visibility scores shown in the master catalog too. The default value is 0 (the horizon).")
            }
            
            // Darkness Threshold
            Section {
                Picker("Darkness Threshold", selection: $reportSettings.darknessThreshold) {
                    Text("Civil Twilight").tag(Int16(0))
                    Text("Nautical Twilight").tag(Int16(1))
                    Text("Astronomical Twilight").tag(Int16(2))
                }
            } footer: {
                Text("The darkness threshold specifies how dark it needs to be in order to be considered night time, or in other words, time that is eligible to be imaging. This setting impacts visibility score. The default value is Civil Twilight.")
            }
            
            // Minimum FOV Coverage
            Section {
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
            } footer: {
                Text("This is the minimum ratio between your scope's FOV length and the target's arc length. The default value is 10%.")
            }
            
            // Minimum Target Visibility Score
            Section {
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
            } footer: {
                Text("The minimum visibility score a target must have in order to be shown in the daily report. The default value is 60%.")
            }
            
            // Filter for Moon Phase
            Section {
                Toggle("Filter For Moon Phase", isOn: $reportSettings.filterForMoonPhase)
                    .foregroundColor(isEnabled ? .primary : .secondary)
            } footer: {
                Text("When enabled, the daily report algorithm will take into consideration the moon's illumination. On an illuminated night, only narrowband targets will be presented. The next two settings further customize this functionality.")
            }
            
            // Maximum Moon for Broadband Suggestions
            Section {
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
            } footer: {
                Text("This value is the cutoff illumination value for what will be considered a moonless night.")
            }
            
            // Prefer Broadband Targets on Moonless Nights
            Section {
                Toggle("Prefer Broadband on Moonless Nights", isOn: $reportSettings.preferBroadband)
                    .foregroundColor(reportSettings.filterForMoonPhase ? .primary : .secondary)
                    .foregroundColor(isEnabled ? .primary : .secondary)
                    .disabled(!reportSettings.filterForMoonPhase)
            } footer: {
                Text("When enabled, narowband targets will be excluded from the daily report, and only broadband targets will be suggested in order to allow the moonless night to be taken advantage of.")
            }
            
        }
        .sheet(isPresented: $isLimitingAltitudeModal) {
            Form {
                NumberPicker(num: $targetSettings.limitingAltitude, placeValues: [.tens, .ones])
            }
            .presentationDetents([.fraction(0.6)])
        }
        .sheet(isPresented: $isMoonPercentModal) {
            Form {
                NumberPicker(num: $reportSettings.maxAllowedMoon, placeValues: [.tenths, .hundredths])
            }
            .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $isMinFOVCoverageModal) {
            Form {
                NumberPicker(num: $reportSettings.minFOVCoverage, placeValues: [.tenths, .hundredths])
            }
            .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $isMinVisibilityModal) {
            Form {
                NumberPicker(num: $reportSettings.minVisibility, placeValues: [.tenths, .hundredths])
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

