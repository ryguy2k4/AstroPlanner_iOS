//
//  EntryTagsEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 1/11/24.
//

import SwiftUI

struct EntryTagsEditor: View {
    @Environment(\.dismiss) var dismiss
    @Binding var tags: Set<JournalEntry.JournalTag>
    @State var tagsProxy: Set<JournalEntry.JournalTag>
    
    init(tags: Binding<Set<JournalEntry.JournalTag>>) {
        self._tags = tags
        self._tagsProxy = State(initialValue: tags.wrappedValue)
    }
    
    var body: some View {
        VStack {
            Section {
                if tagsProxy.isEmpty {
                    Text("No Tags")
                } else {
                    ForEach(Array(tagsProxy), id: \.rawValue) { tag in
                        HStack {
                            Text(tag.rawValue)
                            Button {
                                tagsProxy.remove(tag)
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                        }
                    }
                }
            }
            Divider()
            Section {
                ForEach(JournalEntry.JournalTag.allCases, id: \.rawValue) { tag in
                    if !tagsProxy.contains(tag) {
                        HStack {
                            Button {
                                tagsProxy.insert(tag)
                            } label: {
                                Label(tag.rawValue, systemImage: "plus.circle")
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    self.tags = tagsProxy
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
