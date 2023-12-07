//
//  Mac_HiddenTargetsList.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import SwiftUI
import SwiftData

struct Mac_HiddenTargetsList: View {
    @Environment(\.modelContext) var context
    @Query var targetSettings: [TargetSettings]

    var body: some View {
        VStack {
            if settings.first!.hiddenTargets?.allObjects.isEmpty ?? true {
                Text("No Hidden Targets")
                    .padding()
            }
            List {
                ForEach(settings.first!.hiddenTargets!.allObjects as! [HiddenTarget]) { hiddenTarget in
                    let target = DeepSkyTargetList.allTargets.first(where: {$0.id == hiddenTarget.id})!
                    Text(target.defaultName)
                        .swipeActions() {
                            Button() {
                                settings.first!.removeFromHiddenTargets(hiddenTarget)
                                PersistenceManager.shared.saveData(context: context)

                            } label: {
                                Label("Unhide", systemImage: "eye.fill")
                            }
                            .tint(.green)
                        }
                }
            }
        }
        .navigationTitle("Hidden Targets")
    }
}
