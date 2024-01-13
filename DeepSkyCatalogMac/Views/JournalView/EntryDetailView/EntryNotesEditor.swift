//
//  EntryNotesEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 1/13/24.
//

import SwiftUI

struct EntryNotesEditor: View {
    @Environment(\.dismiss) var dismiss
    @Binding var notes: [String]
    @State var notesProxy: [String]
    @State var newNote: String = ""
    
    init(notes: Binding<[String]>) {
        self._notes = notes
        self._notesProxy = State(initialValue: notes.wrappedValue)
    }
    
    var body: some View {
        VStack {
            Section {
                if notesProxy.isEmpty {
                    Text("No Notes")
                } else {
                    ForEach($notesProxy, id: \.self) { note in
                        HStack {
                            Text(note.wrappedValue)
                            Button {
                                notesProxy.removeAll(where: {$0 == note.wrappedValue})
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                        }
                    }
                }
            }
            Divider()
            Section {
                HStack {
                    Button {
                        if !newNote.isEmpty {
                            notesProxy.append(newNote)
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    TextField("New Note", text: $newNote)
                    Spacer()
                }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    self.notes = notesProxy
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}
