//
//  Mac_JournalView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 10/3/23.
//

import SwiftUI

struct Mac_JournalView: View {
    @State var entries: [JournalEntry] = []
    @State var entryImportModal: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach($entries) { entry in
                    NavigationLink {
                        EntryEditor(entry: entry)
                    } label: {
                        Text("Entry Title Placeholder")
                    }
                }
            }
            .toolbar {
                Button {
                    self.entryImportModal = true
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
        }
        .sheet(isPresented: $entryImportModal) {
            EntryImportModal()
        }
    }
}


