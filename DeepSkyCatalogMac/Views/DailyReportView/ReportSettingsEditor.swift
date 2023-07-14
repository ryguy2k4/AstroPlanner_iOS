//
//  ReportSettingsEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/13/23.
//

import SwiftUI

struct ReportSettingsEditor: View {
    @Environment(\.managedObjectContext) var context
    @Binding var date: Date
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    
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
            get: { return locationList.first! },
            set: {
                for location in locationList { location.isSelected = false }
                $0.isSelected = true
                PersistenceManager.shared.saveData(context: context)
            }
        )
        VStack {
//            DateSelector(date: $date)
            HStack {
                Picker("Imaging Preset", selection: presetBinding) {
                    Text("All").tag(-1)
                    ForEach(presetList.indices) { index in
                        Text(presetList[index].name!).tag(index)
                    }
                }
                Picker("Location", selection: locationBinding) {
                    ForEach(locationList) { location in
                        Text(location.name!).tag(location)
                    }
                }
            }
        }
    }
}

