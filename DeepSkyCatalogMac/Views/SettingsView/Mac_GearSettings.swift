//
//  Mac_GearSettings.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import SwiftUI

struct Mac_GearSettings: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.name, order: .forward)]) var presetList: FetchedResults<ImagingPreset>
    @Environment(\.managedObjectContext) var context
    @State var creatorModal: Bool = false
    @State var editorModal: ImagingPreset? = nil
    
    var body: some View {
        NavigationStack {
            if presetList.isEmpty {
                Text("Add a preset with the plus button")
                    .padding()
            }
            List(presetList) { preset in
                Button(preset.name!) {
                    editorModal = preset
                }
                .buttonStyle(.plain)
            }
            // Button for adding a new preset
            Button {
                creatorModal = true
            } label: {
                Image(systemName: "plus.circle")
            }
        }
        .navigationTitle("Imaging Presets")
        .sheet(isPresented: $creatorModal) {
            ImagingPresetEditor(preset: nil)
        }
        .sheet(item: $editorModal) { preset in
            ImagingPresetEditor(preset: preset)
        }
    }
}

struct ImagingPresetEditor: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @State var showErrorAlert = false
    @FetchRequest(sortDescriptors: []) var presetList: FetchedResults<ImagingPreset>
    
    // Local state variables to hold information being entered
    @State private var name: String = ""
    @State private var focalLength: Double? = nil
    @State private var pixelSize: Double? = nil
    @State private var resolutionLength: Int16? = nil
    @State private var resolutionWidth: Int16? = nil
    let preset: ImagingPreset?
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        // Fields to manually enter gear info
                        TextField("Name", text: $name)
                        // Focal Length
                        TextField("Focal Length (mm): ", value: $focalLength, format: .number)
                        // Pixel Size
                        TextField("Pixel Size (µm): ", value: $pixelSize, format: .number)
                        // Resolution Length
                        TextField("Resolution Length (px): ", value: $resolutionLength, format: .number)
                        // Resolution Width
                        TextField("Resolution Width (px): ", value: $resolutionWidth, format: .number)
                    }
                }
                // Display Pixel Scale and FOV Size
                if let pixelSize = pixelSize, let focalLength = focalLength {
                    let pixelScale = pixelSize / focalLength * 206.2648
                    Text("Pixel Scale: \(pixelScale)")
                    if let resolutionLength = resolutionLength, let resolutionWidth = resolutionWidth {
                        let fovLength = pixelScale * Double(resolutionLength) / 60
                        let fovWidth = pixelScale * Double(resolutionWidth) / 60
                        Text("FOV: \(fovLength)' x \(fovWidth)'")

                    }
                }
                Spacer()
            }
            .frame(minWidth: 300)
            .padding(20)
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button(preset != nil ? "Save \(name)" : "Add \(name)") {
                        if let preset = preset {
                            PersistenceManager.shared.editImagingPreset(preset: preset, name: name, focalLength: focalLength, pixelSize: pixelSize, resLength: resolutionLength, resWidth: resolutionWidth, context: context)
                            dismiss()
                        } else {
                            if let focalLength = focalLength, let pixelSize = pixelSize, let resolutionLength = resolutionLength, let resolutionWidth = resolutionWidth, !presetList.contains(where: {$0.name! == name}) {
                                PersistenceManager.shared.addImagingPreset(name: name, focalLength: focalLength, pixelSize: pixelSize, resLength: resolutionLength, resWidth: resolutionWidth, context: context)
                                dismiss()
                            } else {
                                showErrorAlert = true
                            }
                        }
                    }
                    if let preset = preset {
                        // delete button
                        Button("Delete \(name)", role: .destructive) {
                            context.delete(preset)
                            PersistenceManager.shared.saveData(context: context)
                            dismiss()
                        }
                    }
                }
            }
            .alert("Invalid Preset", isPresented: $showErrorAlert) {
                Button("OK") {
                }
            } message: {
                Text("Every parameter must be filled in or there is already a preset with this name")
            }
            .onAppear() {
                if let preset = preset {
                    self.name = preset.name!
                    self.focalLength = preset.focalLength
                    self.pixelSize = preset.pixelSize
                    self.resolutionLength = preset.resolutionLength
                    self.resolutionWidth = preset.resolutionWidth
                }
            }
        }
    }
}

