//
//  TargetSettings.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/24/23.
//

import SwiftUI
import SwiftData

struct AdvancedSettingsView: View {
    @Environment(\.modelContext) var context
    @Environment(\.isEnabled) var isEnabled
    @Bindable var targetSettings: TargetSettings
    @Bindable var reportSettings: ReportSettings
    @State var isLimitingAltitudeModal: Bool = false
    @State var isMoonPercentModal: Bool = false
    @State var isMinFOVCoverageModal: Bool = false
    @State var isMinVisibilityModal: Bool = false
    
    var body: some View {
        Form {
            
            // Hide Targets that Never Rise
            Section {
                Toggle("Hide Targets that Never Rise", isOn: $targetSettings.hideNeverRises)
                    .tint(.accentColor)
            } footer: {
                Text("By enabling this setting, targets that never rise at the selected location will not appear in the master catalog.")
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
                Text("The limiting altitude determines the rise and set times of each target, and in turn the visibility score, which represents the percentage of the night the target is above this altitude. The default value is 0 (representing the horizon).")
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
                Text("This is the minimum ratio between the length of the imaging preset's field of view and the arc length of the target. The default value is 10%.")
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
                Text("This setting specifies the minimum visibility score a target must have in order to be shown in the daily report. The default value is 60%.")
            }
            
            // Filter for Moon Phase
            Section {
                Toggle("Filter For Moon Phase", isOn: $reportSettings.filterForMoonPhase)
                    .tint(.accentColor)
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
                Text("This value is the cutoff illumination value for what will be considered a moonless night. The default value is 20%.")
            }
            
            // Prefer Broadband Targets on Moonless Nights
            Section {
                Toggle("Prefer Broadband on Moonless Nights", isOn: $reportSettings.preferBroadband)
                    .tint(.accentColor)
                    .foregroundColor(reportSettings.filterForMoonPhase ? .primary : .secondary)
                    .foregroundColor(isEnabled ? .primary : .secondary)
                    .disabled(!reportSettings.filterForMoonPhase)
            } footer: {
                Text("When enabled, narowband targets will be excluded from the daily report on moonless nights and only broadband targets will be suggested. This is to take advantage of moonless nights.")
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
        .navigationTitle("Advanced Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct TargetSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        TargetSettings()
//    }
//}

