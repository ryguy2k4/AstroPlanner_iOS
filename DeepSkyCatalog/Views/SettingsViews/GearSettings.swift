//
//  GearSettings.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/22/22.
//

import SwiftUI

struct GearSettings: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\ImagingPreset.name, order: .forward)]) var presetList: FetchedResults<ImagingPreset>
    @Environment(\.managedObjectContext) var context
    @State private var presetCreatorModal: Bool = false
    @State private var presetEditorModal: ImagingPreset? = nil
    
    var body: some View {
        Form {
            ConfigSection(header: "Imaging Presets", footer: "Swipe left on a preset to delete") {
                // Display each location preset
                List(presetList) { preset in
                    Text(preset.name!)
                        .swipeActions() {
                            if presetList.count > 1 {
                                Button(role: .destructive) {
                                    context.delete(preset)
                                    PersistenceManager.shared.saveData(context: context)
                                    
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            Button {
                                presetEditorModal = preset
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.yellow)
                        }
                        .foregroundColor(.primary)
                }
                // Button for adding a new location
                Button(action: { presetCreatorModal = true }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Preset")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $presetCreatorModal) {
            ImagingPresetCreator(preset: nil)
                .presentationDetents([.fraction(0.8)])
        }
        .sheet(item: $presetEditorModal) { preset in
            ImagingPresetCreator(preset: preset)
                .presentationDetents([.fraction(0.8)])
        }
        .onDisappear {
            PersistenceManager.shared.saveData(context: context)
        }
    }
}

struct ImagingPresetCreator: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @FocusState var isInputActive: Bool
    
    // Local state variables to hold information being entered
    @State private var name: String = ""
    @State private var focalLengthText: String = ""
    @State private var pixelSizeText: String = ""
    @State private var resolutionLength: String = ""
    @State private var resolutionWidth: String = ""
    let preset: ImagingPreset?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ConfigSection {
                        // Fields to manually enter gear info
                        LabeledTextField(text: $name, label: "Name: ", keyboardType: .default)
                            .focused($isInputActive)
                        LabeledTextField(text: $focalLengthText, label: "Focal Length (mm): ")
                            .focused($isInputActive)
                        LabeledTextField(text: $pixelSizeText, label: "Pixel Size (µm): ")
                            .focused($isInputActive)
                        LabeledTextField(text: $resolutionLength, label: "Resolution Length (px): ")
                            .focused($isInputActive)
                        LabeledTextField(text: $resolutionWidth, label: "Resolution Width (px): ")
                            .focused($isInputActive)
                    }
                }
                // Display Pixel Scale and FOV Size
                let pixelScale = (Double(pixelSizeText) ?? .nan) / (Double(focalLengthText) ?? .nan) * 206.2648
                let fovLength = pixelScale * (Double(resolutionLength) ?? .nan) / 60
                let fovWidth = pixelScale * (Double(resolutionWidth) ?? .nan) / 60
                Text("Pixel Scale: \(pixelScale)")
                Text("FOV: \(fovLength)' x \(fovWidth)'")
                Spacer()
            }
            .toolbar {
                KeyboardDismissButton(isInputActive: _isInputActive)
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button(preset != nil ? "Save" : "Add") {
                        if let preset = preset {
                            PersistenceManager.shared.editImagingPreset(preset: preset, name: name, focalLength: Double(focalLengthText), pixelSize: Double(pixelSizeText), resLength: Int16(resolutionLength), resWidth: Int16(resolutionWidth), context: context)
                        } else {
                            PersistenceManager.shared.addImagingPreset(name: name, focalLength: Double(focalLengthText) ?? .nan, pixelSize: Double(pixelSizeText) ?? .nan, resLength: Int16(resolutionLength) ?? 1920, resWidth: Int16(resolutionWidth) ?? 1080, context: context)
                        }
                        dismiss()
                    }
                }
            }
            .padding(0)
        }
        .onAppear() {
            if let preset = preset {
                self.name = preset.name!
                self.focalLengthText = String(preset.focalLength)
                self.pixelSizeText = String(preset.pixelSize)
                self.resolutionLength = String(preset.resolutionLength)
                self.resolutionWidth = String(preset.resolutionWidth)
            }
        }
    }
}

//struct GearSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        GearSettings()
//    }
//}
