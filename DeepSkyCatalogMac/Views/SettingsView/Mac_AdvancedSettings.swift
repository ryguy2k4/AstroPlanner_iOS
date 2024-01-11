//
//  Mac_TargetSettings.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import SwiftUI
import SwiftData

struct Mac_AdvancedSettingsView: View {
    @Environment(\.modelContext) var context
    @Environment(\.isEnabled) var isEnabled
    @Bindable var targetSettings: TargetSettings
    @Bindable var reportSettings: ReportSettings
    
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
                TextField("Lowest acceptable altitude to image: ", value: $targetSettings.limitingAltitude, format: .number)
                    .textFieldStyle(.roundedBorder)
            } footer: {
                Text("The limiting altitude determines the rise and set times of each target, and in turn the visibility score, which represents the percentage of the night the target is above this altitude. The default value is 0 (representing the horizon).")
            }
            
            // Minimum FOV Coverage
            Section {
                TextField("Minimum FOV Coverage: ", value: $reportSettings.minFOVCoverage, format: .percent)
                    .textFieldStyle(.roundedBorder)
            } footer: {
                Text("This is the minimum ratio between the length of the imaging preset's field of view and the arc length of the target. The default value is 10%.")
            }
            
            // Minimum Target Visibility Score
            Section {
                TextField("Minimum Visibility Score: ", value: $reportSettings.minVisibility, format: .percent)
                    .textFieldStyle(.roundedBorder)
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
                TextField("Max Moon for Broadband: ", value: $reportSettings.maxAllowedMoon, format: .percent)
                    .textFieldStyle(.roundedBorder)
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
        .formStyle(.grouped)
    }
}
