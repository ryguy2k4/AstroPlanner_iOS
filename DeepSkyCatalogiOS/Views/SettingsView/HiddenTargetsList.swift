//
//  HiddenTargetsList.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/28/23.
//

import SwiftUI

struct HiddenTargetsList: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var settings: FetchedResults<TargetSettings>

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
        .navigationBarTitleDisplayMode(.inline)
    }
}
