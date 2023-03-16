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
    @Environment(\.data) var data
    @ObservedObject var settings: ReportSettings
    @Binding var date: Date
    @Binding var viewingInterval: DateInterval
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @State var isMoonPercentModal: Bool = false
    @State var isLimitingAltitudeModal: Bool = false
    @State var isMinFOVCoverageModal: Bool = false
    @State var isMinVisibilityModal: Bool = false

    init(date: Binding<Date>, viewingInterval: Binding<DateInterval>) {
        self._date = date
        self._viewingInterval = viewingInterval
        self.settings = try! PersistenceManager.shared.container.viewContext.fetch(NSFetchRequest<ReportSettings>(entityName: "ReportSettings")).first!
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
        let locationBinding = Binding(
            get: { return locationList.firstIndex(where: {$0.isSelected == true}) ?? -1 },
            set: {
                for location in locationList { location.isSelected = false }
                if $0 >= 0 {
                    locationList[$0].isSelected = true
                }
                PersistenceManager.shared.saveData(context: context)
            }
        )
        NavigationStack {
            VStack {
                DateSelector(date: $date)
                    .padding()
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Form {
                    ConfigSection(header: "Viewing Interval") {
                        DateIntervalSelector(viewingInterval: $viewingInterval, customViewingInterval: viewingInterval != data?.sun.ATInterval, sun: data?.sun)
                    }
                    ConfigSection(header: "Report Settings") {
                        Picker("Location", selection: locationBinding) {
//                            Text("Current Location").tag(-1)
                            ForEach(Array(locationList.enumerated()), id: \.element) { index, location in
                                Text(locationList[index].name!).tag(index)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        Picker("Imaging Preset", selection: presetBinding) {
                            Text("All").tag(-1)
                            ForEach(Array(presetList.enumerated()), id: \.element) { index, preset in
                                Text(presetList[index].name!).tag(index)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        Toggle("Prefer Broadband on Moonless Nights", isOn: $settings.preferBroadband)
                            .foregroundColor(isEnabled ? .primary : .secondary)
                        Button {
                            isMoonPercentModal = true
                        } label: {
                            HStack {
                                Text("Max Moon for Broadband: ")
                                    .foregroundColor(isEnabled ? .primary : .secondary)
                                Spacer()
                                Text(settings.maxAllowedMoon.percent())
                            }
                            
                        }
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
                                Text("Minimum Visibility: ")
                                    .foregroundColor(isEnabled ? .primary : .secondary)
                                Spacer()
                                Text(settings.minVisibility.percent())
                            }
                            
                        }
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
            .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $isMinFOVCoverageModal) {
            Form {
                ConfigSection(footer: "This is the minimum ratio between your scope's FOV length and the target's arc length. Should probably be around 25%") {
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
