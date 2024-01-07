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
    @State var creating = false
    @State var ninaImagePlanURL: URL? = nil
    @State var ninaLogFileURL: URL? = nil
    @State var APTLogFileURL: URL? = nil
    @State var fitsURLs: Set<URL>? = nil
    @State var rawURLs: Set<URL>? = nil
    @State var fileImporter = false
    @Binding var entries: [JournalEntry]
    var body: some View {
        if !creating {
            VStack {
                FileChooser(title: "Import NINA Log File", allowedContentTypes: [.init(filenameExtension: "log")!], resultURL: $ninaLogFileURL)
                    .disabled(APTLogFileURL != nil)
                FileChooser(title: "Import NINA Image Plan", allowedContentTypes: [.xml], resultURL: $ninaImagePlanURL)
                    .disabled(APTLogFileURL != nil)
                FileChooser(title: "Import APT Log File", allowedContentTypes: [.text], resultURL: $APTLogFileURL)
                    .disabled(ninaLogFileURL != nil || ninaImagePlanURL != nil)
                MultipleFileChooser(title: "Import FITS Files", allowedContentTypes: [.init(filenameExtension: "fits")!], resultURLs: $fitsURLs)
                    .disabled(rawURLs != nil)
                MultipleFileChooser(title: "Import RAW Files", allowedContentTypes: [.init(filenameExtension: "cr2")!], resultURLs: $rawURLs)
                    .disabled(fitsURLs != nil)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create New Entry") {
                        creating = true
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .frame(minWidth: 600, maxWidth: 1200, minHeight: 400,  maxHeight: 800)
        } else {
            ProgressView("Creating New Entry")
                .padding()
                .task {
                    let ninaImagePlan: () -> CaptureSequenceList? = {
                        if let planURL = ninaImagePlanURL, let ninaImagePlanData = try? Data(contentsOf: planURL), let ninaImagePlan = try? XMLDecoder().decode(CaptureSequenceList.self, from: ninaImagePlanData) {
                            return ninaImagePlan
                        }
                        return nil
                    }
                    
                    let ninaLog: () -> NINALogFile? = {
                        if let logURL = ninaLogFileURL, let ninaLog = NINALogFile(from: logURL) {
                            return ninaLog
                        }
                        return nil
                    }
                    
                    let fitsMetadata: () -> [FITSKeywords]? = {
                        return fitsURLs?.map({FITSKeywords(from: $0)})
                    }
                    
                    let aptLog: () -> APTLogFile? = {
                        if let logURL = APTLogFileURL, let aptLog = APTLogFile(from: logURL) {
                            return aptLog
                        }
                        return nil
                    }
                    
                    let exifMetadata: [EXIFMetadata]? = rawURLs?.map({EXIFMetadata(from: $0)})
                    
                    let newEntry = await JournalImportManager.generate(ninaImagePlan: ninaImagePlan(), ninaLog: ninaLog(), fitsMetadata: fitsMetadata()?.sorted(by: {$0.date < $1.date}), aptLog: aptLog(), rawMetadata: exifMetadata?.sorted(by: {$0.dateTimeOriginal < $1.dateTimeOriginal}))
                    entries.append(newEntry)
                    dismiss()
                }
        }
    }
}


struct FileChooser: View {
    @Environment(\.isEnabled) var enabled
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
        .opacity(enabled ? 1 : 0.5)
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
    @Environment(\.isEnabled) var enabled
    let title: String
    let allowedContentTypes: [UTType]
    @State var showFileImporter = false
    @Binding var resultURLs: Set<URL>?
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Section {
                    if let resultURL = resultURLs {
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
        .opacity(enabled ? 1 : 0.5)
        .padding()
        .border(.selection)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: allowedContentTypes, allowsMultipleSelection: true) { result in
            if resultURLs != nil, let results = try? result.get() {
                resultURLs!.formUnion(results)
            } else {
                resultURLs = Set((try? result.get()) ?? [])
            }
            
        }
    }
}
