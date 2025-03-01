//
//  Mac_TopTenTabView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/13/23.
//

import SwiftUI

enum TargetTab: String, Identifiable, CaseIterable {
    var id: Self { self }
    case nebulae = "Nebulae"
    case galaxies = "Galaxies"
    case starClusters = "Star Clusters"
}

struct Mac_TopTenListView: View {
    let reportList: [DeepSkyTarget]
    let targetTab: TargetTab
    
    @Binding var selection: DeepSkyTarget?
    
    var body: some View {
        VStack {
            Text(targetTab.rawValue)
                .fontWeight(.bold)
            if !reportList.isEmpty {
                List(reportList) { target in
                    Text(target.defaultName)
                        .onTapGesture {
                            if selection == target {
                                selection = nil
                            } else {
                                selection = target
                            }
                        }
                        .listRowBackground(target == selection ? Color.accentColor.opacity(0.5) : Color.clear)
                }
                .tag(targetTab)
                .listStyle(.inset)
            } else {
                List {
                    Text("No \(targetTab.rawValue) :/")
                }
            }
        }
        .frame(minWidth: 200, idealWidth: 400, maxWidth: 400, minHeight: 300, idealHeight: 300, alignment: .center)
    }
}
