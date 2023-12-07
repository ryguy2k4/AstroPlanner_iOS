//
//  GearSettings.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/22/22.
//

import SwiftUI
import SwiftData

struct GearSettings: View {
    @Query var presetList: [ImagingPreset]
    @Environment(\.modelContext) var context
    
    var body: some View {
        NavigationStack {
            if presetList.isEmpty {
                Text("Add a preset with the plus button")
                    .padding()
            }
            List(presetList) { preset in
                NavigationLink(destination: ImagingPresetEditor(preset: preset)) {
                    Text(preset.name)
                        .foregroundColor(.primary)
                }
            }
            .toolbar() {
                // Button for adding a new preset
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ImagingPresetEditor(preset: nil)) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .navigationTitle("Imaging Presets")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ImagingPresetEditor: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @FocusState var isInputActive: Bool
    @State var showErrorAlert = false
    @Query var presetList: [ImagingPreset]
    
    // Local state variables to hold information being entered
    @State private var name: String = ""
    @State private var focalLength: Double? = nil
    @State private var pixelSize: Double? = nil
    @State private var resolutionLength: Int? = nil
    @State private var resolutionWidth: Int? = nil
    let preset: ImagingPreset?
    
    var body: some View {
        NavigationStack {
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
                    if let preset = preset {
                        Section {
                            // delete button
                            Button("Delete \(name)", role: .destructive) {
                                context.delete(preset)
                                dismiss()
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
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
//                ToolbarItemGroup(placement: .confirmationAction) {
//                    Button(preset != nil ? "Save \(name)" : "Add \(name)") {
//                        if let preset = preset {
////                            PersistenceManager.shared.editImagingPreset(preset: preset, name: name, focalLength: focalLength, pixelSize: pixelSize, resLength: resolutionLength, resWidth: resolutionWidth, context: context)
//                            dismiss()
//                        } else {
//                            if let focalLength = focalLength, let pixelSize = pixelSize, let resolutionLength = resolutionLength, let resolutionWidth = resolutionWidth, !presetList.contains(where: {$0.name! == name}) {
////                                PersistenceManager.shared.addImagingPreset(name: name, focalLength: focalLength, pixelSize: pixelSize, resLength: resolutionLength, resWidth: resolutionWidth, context: context)
//                                dismiss()
//                            } else {
//                                showErrorAlert = true
//                            }
//                        }
//                    }
//                }
            }
            .padding(0)
            .alert("Invalid Preset", isPresented: $showErrorAlert) {
                Button("OK") {
                }
            } message: {
                Text("Every parameter must be filled in or there is already a preset with this name")
            }
            .onAppear() {
                if let preset = preset {
                    self.name = preset.name
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
