//
//  Mac_JournalView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 10/3/23.
//

import SwiftUI

struct Mac_JournalView: View {
    @State var entries: [JournalEntry] = JournalEntryList.allEntries.sorted(by: {$0.imagingInterval?.start ?? .distantPast > $1.imagingInterval?.start ?? .distantPast})
    @State var entryImportModal: Bool = false
    @State var entryIndex: Int?

    var body: some View {
        NavigationSplitView {
            List(entries.indices, id: \.self, selection: $entryIndex) { index in
                Text((entries[index].imagingInterval?.start ?? .distantPast).formatted(date: .numeric, time: .omitted) + " - " + (entries[index].target?.targetID?.name ?? "Unknown Target"))
                    .tag(index)
                    .padding()
            }
            .listStyle(.bordered)
            .toolbar {
                Button {
                    self.entryImportModal = true
                } label: {
                    Image(systemName: "plus.circle")
                }.help("New Entry")
                if let entryIndex = entryIndex {
                    Button {
                        entries.remove(at: entryIndex)
                    } label: {
                        Image(systemName: "trash")
                    }.help("Delete Entry")
                }
                Button {
                    JournalEntryList.exportObjects(list: entries)
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }.help("Save Journal")
                
            }
            .sheet(isPresented: $entryImportModal) {
                EntryImportModal(entries: $entries)
            }
        } detail: {
            if !entries.isEmpty, let entryIndex = entryIndex {
                EntryDetailView(entry: entries[entryIndex])
                    .navigationSplitViewColumnWidth(min: 400, ideal: 400)
            } else if entries.isEmpty {
                ContentUnavailableView("Create an Entry", systemImage: "plus.circle")
                    .navigationSplitViewColumnWidth(min: 400, ideal: 400)
            } else {
                ContentUnavailableView("Select an Entry", systemImage: "doc.richtext")
                    .navigationSplitViewColumnWidth(min: 400, ideal: 400)
            }
        }
    }
}


