//
//  EntryTargetEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/23/23.
//

import SwiftUI

struct EntryTargetEditor: View {
    @Environment(\.dismiss) var dismiss
    @Binding var target: JournalEntry.JournalTarget?
    @State var targetName: String
    @State var centerRA: Double?
    @State var centerDec: Double?
    @State var rotation: Double?
    
    init(target: Binding<JournalEntry.JournalTarget?>) {
        self._target = target
        self._centerRA = State(initialValue: target.wrappedValue?.centerRA)
        self._centerDec = State(initialValue: target.wrappedValue?.centerDEC)
        self._rotation = State(initialValue: target.wrappedValue?.rotation)
        switch target.wrappedValue?.targetID {
        case .catalog(let id):
            self._targetName = State(initialValue: id.uuidString)
        case .custom(let name):
            self._targetName = State(initialValue: name)
        case nil:
            self._targetName = State(initialValue: "")
        }
    }
    var body: some View {
        VStack {
            if let target = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == targetName}) {
                HStack {
                    Text("Catalog Match: " + target.defaultName)
                        .foregroundColor(.accentColor)
                    Button("Update Coordinates") {
                        centerRA = target.ra
                        centerDec = target.dec
                    }
                }
            } else {
                Text("No Catalog Match: Save as Custom")
                    .foregroundColor(.secondary)
            }
            TargetIDSearchField(searchText: $targetName)
            TextField("Center RA:", value: $centerRA, format: .number)
            TextField("Center Dec:", value: $centerDec, format: .number)
            TextField("Rotation:", value: $rotation, format: .number)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if self.target == nil {
                        self.target = .init(targetID: .init(targetName: "Unknown Target"), centerRA: 0, centerDEC: 0, rotation: 0)
                    }
                    if let id = UUID(uuidString: targetName) {
                        self.target?.targetID = .catalog(id: id)
                    } else if !targetName.isEmpty {
                        self.target?.targetID = .custom(name: targetName)
                    }
                    self.target?.centerRA = centerRA
                    self.target?.centerDEC = centerDec
                    self.target?.rotation = rotation
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
                    self.target = nil
                    dismiss()
                }
            }
        }
    }
}
