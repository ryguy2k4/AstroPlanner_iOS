//
//  HiddenTargetsList.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/28/23.
//

import SwiftUI
import SwiftData
import DeepSkyCore

struct HiddenTargetsList: View {
    @Environment(\.modelContext) var context
    @Query var targetSettings: [TargetSettings]

    var body: some View {
        VStack {
            if targetSettings.first!.hiddenTargets!.isEmpty {
                ContentUnavailableView("Hidden Targets is Empty", systemImage: "eye.slash")
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
        .navigationBarTitleDisplayMode(.inline)
    }
}
