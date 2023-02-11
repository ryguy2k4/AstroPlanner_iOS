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
                            Button(role: .destructive) {
                                context.delete(preset)
                                PersistenceManager.shared.saveData(context: context)
                                
                            } label: {
                                Label("Delete", systemImage: "trash")
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
    @State var showErrorAlert = false
    
    // Local state variables to hold information being entered
    @State private var name: String = ""
    @State private var focalLength: Double? = nil
    @State private var pixelSize: Double? = nil
    @State private var resolutionLength: Int16? = nil
    @State private var resolutionWidth: Int16? = nil
    let preset: ImagingPreset?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ConfigSection {
                        // Fields to manually enter gear info
                        LabeledTextField(text: $name, label: "Name: ", keyboardType: .default)
                            .focused($isInputActive)
                        // Focal Length
                        HStack {
                            Text("Focal Length (mm): ")
                                .font(.callout)
                            TextField("Focal Length (mm): ", value: $focalLength, format: .number)
                                .keyboardType(.numbersAndPunctuation)
                                .focused($isInputActive)
                        }
                        // Pixel Size
                        HStack {
                            Text("Pixel Size (µm): ")
                                .font(.callout)
                            TextField("Pixel Size (µm): ", value: $pixelSize, format: .number)
                                .keyboardType(.numbersAndPunctuation)
                                .focused($isInputActive)
                        }
                        // Resolution Length
                        HStack {
                            Text("Resolution Length (px): ")
                                .font(.callout)
                            TextField("Resolution Length (px): ", value: $resolutionLength, format: .number)
                                .keyboardType(.numbersAndPunctuation)
                                .focused($isInputActive)
                        }
                        // Resolution Width
                        HStack {
                            Text("Resolution Width (px): ")
                                .font(.callout)
                            TextField("Resolution Width (px): ", value: $resolutionWidth, format: .number)
                                .keyboardType(.numbersAndPunctuation)
                                .focused($isInputActive)
                        }
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
            .toolbar {
                KeyboardDismissButton(isInputActive: _isInputActive)
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button(preset != nil ? "Save" : "Add") {
                        if let preset = preset {
                            PersistenceManager.shared.editImagingPreset(preset: preset, name: name, focalLength: focalLength, pixelSize: pixelSize, resLength: resolutionLength, resWidth: resolutionWidth, context: context)
                            dismiss()
                        } else {
                            if let focalLength = focalLength, let pixelSize = pixelSize, let resolutionLength = resolutionLength, let resolutionWidth = resolutionWidth {
                                PersistenceManager.shared.addImagingPreset(name: name, focalLength: focalLength, pixelSize: pixelSize, resLength: resolutionLength, resWidth: resolutionWidth, context: context)
                                dismiss()
                            } else {
                                showErrorAlert = true
                            }
                        }
                    }
                }
            }
            .padding(0)
            .alert("Invalid Preset", isPresented: $showErrorAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Fill in every parameter")
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

//struct GearSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        GearSettings()
//    }
//}
