//
//  EntryGearEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/23/23.
//

import SwiftUI
import SwiftData

struct EntryGearEditor: View {
    @Environment(\.dismiss) var dismiss
    @Query(sort: [SortDescriptor(\ImagingPreset.name, order: .forward)]) var presetList: [ImagingPreset]
    @Binding var gear: JournalEntry.JournalGear?
    @State var gearProxy: JournalEntry.JournalGear
    
    init(gear: Binding<JournalEntry.JournalGear?>) {
        self._gear = gear
        self._gearProxy = State(initialValue: gear.wrappedValue ?? JournalEntry.JournalGear.default)
    }
    
    var body: some View {
        let telescopeBinding = Binding(
            get: { return gearProxy.telescopeName ?? ""},
            set: { gearProxy.telescopeName = $0}
        )
        let cameraBinding = Binding(
            get: { return gearProxy.cameraName ?? ""},
            set: { gearProxy.cameraName = $0}
        )
        let filterWheelBinding = Binding(
            get: { return gearProxy.filterWheelName ?? ""},
            set: { gearProxy.filterWheelName = $0}
        )
        let mountBinding = Binding(
            get: { return gearProxy.mountName ?? ""},
            set: { gearProxy.mountName = $0}
        )
        let savedPresetBinding = Binding(
            get: { return gearProxy },
            set: { newValue in
                gearProxy.focalLength = newValue.focalLength
                gearProxy.pixelSize = newValue.pixelSize
                gearProxy.resolutionLength = newValue.resolutionLength
                gearProxy.resolutionWidth = newValue.resolutionWidth
            }
        )
        VStack {
            TextField("Telescope", text: telescopeBinding)
            TextField("Focal Length", value: $gearProxy.focalLength, format: .number)
            TextField("Camera", text: cameraBinding)
            TextField("Pixel Size", value: $gearProxy.pixelSize, format: .number)
            TextField("Resolution Width", value: $gearProxy.resolutionWidth, format: .number)
            TextField("Resolution Length", value: $gearProxy.resolutionLength, format: .number)
            TextField("Filter Wheel", text: filterWheelBinding)
            TextField("Mount", text: mountBinding)
            Picker("Saved:", selection: savedPresetBinding) {
                ForEach(presetList) { saved in
                    Text(saved.name).tag(JournalEntry.JournalGear(from: saved))
                }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    self.gear = self.gearProxy
                    if let name = gearProxy.telescopeName, name.isEmpty {
                        self.gear?.telescopeName = nil
                    }
                    if let name = gearProxy.cameraName, name.isEmpty {
                        self.gear?.cameraName = nil
                    }
                    if let name = gearProxy.filterWheelName, name.isEmpty {
                        self.gear?.filterWheelName = nil
                    }
                    if let name = gearProxy.mountName, name.isEmpty {
                        self.gear?.mountName = nil
                    }
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button("Remove") {
                    self.gear = nil
                    dismiss()
                }
            }
        }
    }
}
