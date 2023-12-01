//
//  Mac_JournalView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 10/3/23.
//

import SwiftUI
import WeatherKit
import XMLParsing

struct Mac_JournalView: View {
    @State var entries: [JournalEntry] = JournalEntryList.allEntries
    @State var info: [String]?
    @State var log: [String]?
    @State var plan: CaptureSequenceList?

    var body: some View {
        let infoBinding = Binding(
            get: { return info != nil },
            set: { _,_ in }
        )
        let logBinding = Binding(
            get: { return log != nil },
            set: { _,_ in }
        )
        let planBinding = Binding(
            get: { return plan != nil },
            set: { _,_ in }
        )
            HStack {
                Spacer()
                DragNDropBox(label: "Info.txt", enabled: infoBinding)
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                if let url = object, let string = try? String(contentsOf: url, encoding: .utf8) {
                                    self.info = string.components(separatedBy: "\n")
                                }
                            }
                            return true
                        }
                        return false
                    }
                Spacer()
                DragNDropBox(label: "NINA Log", enabled: logBinding)
                    .onDrop(of: [.fileURL], isTargeted: nil){ providers in
                        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                if let url = object, let string = try? String(contentsOf: url, encoding: .utf8) {
                                    let lines = string.components(separatedBy: "\n")
                                    self.log = lines
                                }
                            }
                            return true
                        }
                        return false
                    }
                Spacer()
                DragNDropBox(label: "Image Plan", enabled: planBinding)
                    .onDrop(of: [.fileURL], isTargeted: nil){ providers in
                        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                if let url = object, let string = try? String(contentsOf: url, encoding: .utf8) {
                                    let xmlData = Data(string.utf8)
                                    let decoder = XMLDecoder()
                                    let imagePlan = try? decoder.decode(CaptureSequenceList.self, from: xmlData)
                                    self.plan = imagePlan
                                }
                            }
                            return true
                        }
                        return false
                    }
                Spacer()
            }
            .padding()
            .background(.tertiary)
            .border(.secondary)
        
        NavigationSplitView {
            List {
                ForEach(Array(entries.enumerated()), id: \.offset) { index, object in
                    NavigationLink {
                        EntryEditor(entry: $entries[index])
                    } label: {
//                        Text("\(entries[index].setupInterval?.start.formatted(date: .abbreviated, time: .omitted)): \(target?.name?.first ?? target?.defaultName ?? "???")")
                        Text(object.targetName)
                    }
                }
            }
            .toolbar {
                Button {
                    entries.append(JournalEntry(info: self.info, log: self.log, plan: self.plan))
                    self.info = nil
                    self.log = nil
                    self.plan = nil
                } label: {
                    Image(systemName: "plus.circle")
                }
                Button {
                    self.info = nil
                    self.log = nil
                    self.plan = nil
                } label: {
                    Text("Clear Files")
                }
                Button {
                    JournalEntryList.exportObjects(list: self.entries)
                } label: {
                    Text("Save Entries")
                }


            }
        } detail: {
            Text("Select an Entry")
        }
    }
}

struct DragNDropBox: View {
    let label: String
    @Binding var enabled: Bool
    var body: some View {
        VStack {
            Label(label, systemImage: "square.and.arrow.down.on.square")
                .frame(minWidth: 150, minHeight: 150)
                .border(.red)
                .background(enabled ? Color.red : nil)
            Text(enabled ? "OK" : "No File")
                .foregroundStyle(enabled ? .green : .red, .secondary)
        }
    }
}
