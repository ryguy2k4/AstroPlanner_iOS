//
//  EntryImportModal.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/17/23.
//

import SwiftUI
import WeatherKit
import XMLParsing
import UniformTypeIdentifiers

struct EntryImportModal: View {
    @Environment(\.dismiss) var dismiss
    @State var entryCreateModal: Bool = false
    @State var ninaImagePlanURL: URL? = nil
    @State var ninaLogFileURL: URL? = nil
    @State var fitsURLs: [URL]? = nil
    @State var fileImporter = false
    var body: some View {
        VStack {
            FileChooser(title: "Import NINA Log File", allowedContentTypes: [.text], resultURL: $ninaLogFileURL)
            FileChooser(title: "Import NINA Image Plan", allowedContentTypes: [.xml], resultURL: $ninaImagePlanURL)
            MultipleFileChooser(title: "Import FITS Files", allowedContentTypes: [.init(filenameExtension: "fits")!], resultURL: $fitsURLs)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Create New Entry") {
                    entryCreateModal = true
                    dismiss()
                }
            }
        }
        .frame(minWidth: 600, maxWidth: 1200, minHeight: 400,  maxHeight: 800)
        .sheet(isPresented: $entryCreateModal) {
            EntryCreateModal(ninaImagePlanURL: ninaImagePlanURL, ninaLogFileURL: ninaLogFileURL, fitsURLs: fitsURLs)
        }
    }
}

struct FileChooser: View {
    let title: String
    let allowedContentTypes: [UTType]
    @State var showFileImporter = false
    @State var dragHover = false
    @Binding var resultURL: URL?
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Section {
                        if let resultURL = resultURL {
                            Text("File: " + resultURL.lastPathComponent)
                        } else {
                            Text("Drag or Browse for File")
                                .font(.italic(.body)())
                        }
                    } header: {
                        HStack {
                            Text(title)
                                .font(.title)
                            Button {
                                showFileImporter = true
                            } label: {
                                Image(systemName: "folder.badge.plus")
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            if dragHover {
                Image(systemName: "square.and.arrow.down.on.square")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.primary)
            }
        }
        .frame(minHeight: 100)
        .padding()
        .border(.selection)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: allowedContentTypes) { result in
            resultURL = try? result.get()
        }
        .onDrop(of: [.fileURL], isTargeted: $dragHover) { providers in
            if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                    if let url = object {
                        resultURL = url
                    }
                }
                return true
            }
            return false
        }
    }
}

struct MultipleFileChooser: View {
    let title: String
    let allowedContentTypes: [UTType]
    @State var showFileImporter = false
    @Binding var resultURL: [URL]?
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Section {
                    if let resultURL = resultURL {
                        Text("\(resultURL.count) Files Selected")
                    } else {
                        Text("Browse for Files")
                            .font(.italic(.body)())
                    }
                } header: {
                    HStack {
                        Text(title)
                            .font(.title)
                        Button {
                            showFileImporter = true
                        } label: {
                            Image(systemName: "folder.badge.plus")
                        }
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .frame(minHeight: 100)
        .padding()
        .border(.selection)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: allowedContentTypes, allowsMultipleSelection: true) { result in
            resultURL = try? result.get()
        }
    }
}
