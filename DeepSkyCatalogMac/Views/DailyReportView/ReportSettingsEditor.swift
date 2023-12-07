//
//  ReportSettingsEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/13/23.
//

import SwiftUI
import SwiftData

struct ReportSettingsEditor: View {
    @Environment(\.modelContext) var context
    @Binding var date: Date
    @Query var presetList: [ImagingPreset]
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: [SavedLocation]
    
    var body: some View {
        let presetBinding = Binding(
            get: { return presetList.firstIndex(where: {$0.isSelected == true}) ?? -1 },
            set: {
                for preset in presetList { preset.isSelected = false }
                if $0 >= 0 {
                    presetList[$0].isSelected = true
                }
            }
        )
        let locationBinding = Binding(
            get: { return locationList.first! },
            set: {
                for location in locationList { location.isSelected = false }
                $0.isSelected = true
            }
        )
        VStack {
//            DateSelector(date: $date)
            HStack {
                Picker("Imaging Preset", selection: presetBinding) {
                    Text("All").tag(-1)
                    ForEach(presetList.indices) { index in
                        Text(presetList[index].name).tag(index)
                    }
                }
                Picker("Location", selection: locationBinding) {
                    ForEach(locationList) { location in
                        Text(location.name).tag(location)
                    }
                }
            }
        }
    }
}

