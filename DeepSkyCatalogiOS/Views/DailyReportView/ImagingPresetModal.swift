//
//  ImagingPresetModal.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 8/4/23.
//

import SwiftUI

struct ImagingPresetModal: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.isSelected, order: .reverse)]) var presetList: FetchedResults<ImagingPreset>
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
        Form {
            Picker("Imaging Preset", selection: presetBinding) {
                Text("None").tag(-1)
                ForEach(Array(presetList.enumerated()), id: \.element) { index, preset in
                    Text(presetList[index].name!).tag(index)
                }
            }
            .pickerStyle(.inline)
            .headerProminence(.increased)
        }
    }
}
