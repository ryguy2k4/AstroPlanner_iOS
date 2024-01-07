//
//  Mac_JournalView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 10/3/23.
//

import SwiftUI

struct Mac_JournalView: View {
    @State var entries: [JournalEntry] = JournalEntryList.allEntries
    @State var entryImportModal: Bool = false
    @State var entryIndex: Int = 0

    var body: some View {
        NavigationSplitView {
            List(entries.indices, id: \.self, selection: $entryIndex) { index in
                Text(entries[index].target?.targetID?.name ?? "Unknown Target")
            }
            .toolbar {
                Button {
                    self.entryImportModal = true
                } label: {
                    Image(systemName: "plus.circle")
                }.help("New Entry")
                Button {
                    entries.remove(at: entryIndex)
                } label: {
                    Image(systemName: "trash")
                }.help("Delete Entry")
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
            if !entries.isEmpty {
                EntryDetailView(entry: entries[entryIndex])
            } else {
                Text("Create an Entry")
            }
        }
    }
}


