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
            if targetSettings.first!.hiddenTargets!.isEmpty {
                Text("No Hidden Targets")
                    .padding()
            }
            List {
                ForEach(targetSettings.first!.hiddenTargets!) { hiddenTarget in
                    let target = DeepSkyTargetList.allTargets.first(where: {$0.id == hiddenTarget.id})!
                    Text(target.defaultName)
                        .swipeActions() {
                            Button() {
                                context.delete(hiddenTarget)

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
