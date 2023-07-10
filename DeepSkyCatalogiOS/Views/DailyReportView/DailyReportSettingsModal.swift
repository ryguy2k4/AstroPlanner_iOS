//
//  DailyReportSettings.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/21/22.
//

import SwiftUI
import CoreData

struct DailyReportSettingsModal: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.isEnabled) var isEnabled
    @ObservedObject var settings: ReportSettings
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
    @FetchRequest(sortDescriptors: []) var reportSettings: FetchedResults<ReportSettings>
    @State var isMoonPercentModal: Bool = false
    @State var isLimitingAltitudeModal: Bool = false
    @State var isMinFOVCoverageModal: Bool = false
    @State var isMinVisibilityModal: Bool = false

    init() {
        self.settings = try! PersistenceManager.shared.container.viewContext.fetch(ReportSettings.fetchRequest()).first!
    }
    
    var body: some View {
        let presetBinding = Binding(
            get: { return presetList.firstIndex(where: {$0.isSelected == true}) ?? -1 },
            set: {
                for preset in presetList { preset.isSelected = false }
                if $0 >= 0 {
                    presetList[$0].isSelected = true
                }
                PersistenceManager.shared.saveData(context: context)
            }
        )
        NavigationStack {
            Form {
                ConfigSection(header: "Report Settings") {
                    Picker("Imaging Preset", selection: presetBinding) {
                        Text("All").tag(-1)
                        ForEach(Array(presetList.enumerated()), id: \.element) { index, preset in
                            Text(presetList[index].name!).tag(index)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Button {
                        isMinFOVCoverageModal = true
                    } label: {
                        HStack {
                            Text("Minimum FOV Coverage: ")
                                .foregroundColor(isEnabled ? .primary : .secondary)
                            Spacer()
                            Text(settings.minFOVCoverage.percent())
                        }
                    }
                    Button {
                        isMinVisibilityModal = true
                    } label: {
                        HStack {
                            Text("Minimum Visibility Score: ")
                                .foregroundColor(isEnabled ? .primary : .secondary)
                            Spacer()
                            Text(settings.minVisibility.percent())
                        }
                        
                    }
                    
                    Toggle("Filter For Moon Phase", isOn: $settings.filterForMoonPhase)
                        .foregroundColor(isEnabled ? .primary : .secondary)
                    
                    Button {
                        isMoonPercentModal = true
                    } label: {
                        HStack {
                            Text("Max Moon for Broadband: ")
                                .foregroundColor(settings.filterForMoonPhase ? .primary : .secondary)
                                .foregroundColor(isEnabled ? .primary : .secondary)
                            Spacer()
                            Text(settings.maxAllowedMoon.percent())
                        }
                        
                    }
                    .disabled(!settings.filterForMoonPhase)
                    
                    Toggle("Prefer Broadband on Moonless Nights", isOn: $settings.preferBroadband)
                        .foregroundColor(settings.filterForMoonPhase ? .primary : .secondary)
                        .foregroundColor(isEnabled ? .primary : .secondary)
                        .disabled(!settings.filterForMoonPhase)
                }
            }
        }
        .sheet(isPresented: $isMoonPercentModal) {
            Form {
                ConfigSection(footer: "If the moon illumination is greater than this value, then broadband targets will not be suggested.") {
                    NumberPicker(num: $settings.maxAllowedMoon, placeValues: [.tenths, .hundredths])
                }
            }
            .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $isMinFOVCoverageModal) {
            Form {
                ConfigSection(footer: "This is the minimum ratio between your scope's FOV length and the target's arc length. Should probably be around 25%.") {
                    NumberPicker(num: $settings.minFOVCoverage, placeValues: [.tenths, .hundredths])
                }
            }
            .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $isMinVisibilityModal) {
            Form {
                ConfigSection(footer: "Targets shown in the daily report must be visible for at least this percentage of the night.") {
                    NumberPicker(num: $settings.minVisibility, placeValues: [.tenths, .hundredths])
                }
            }
            .presentationDetents([.fraction(0.4)])
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
