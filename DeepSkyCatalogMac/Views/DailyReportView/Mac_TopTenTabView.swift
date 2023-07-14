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

/**
 This View is a TabView that uses a Segmented Picker to switch between tabs.
 Each Tab displays the 3 topFive arrays defined in the report.
 */
struct Mac_TopTenTabView: View {
    let report: DailyReport
    
    @Binding var tabSelection: TargetTab
    
    var body: some View {
        VStack {
            Picker("Tab", selection: $tabSelection) {
                ForEach(TargetTab.allCases) { tab in
                    Text(tab.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            
            TabView(selection: $tabSelection) {
                TopTenListView(reportList: report.topTenNebulae, targetTab: .nebulae)
                TopTenListView(reportList: report.topTenGalaxies, targetTab: .galaxies)
                TopTenListView(reportList: report.topTenStarClusters, targetTab: .starClusters)
            }
        }
        .scrollDisabled(true)
        .padding(.vertical)
        .frame(minHeight: 400)
    }
}

fileprivate struct TopTenListView: View {
    let reportList: [DeepSkyTarget]
    let targetTab: TargetTab
    
    var body: some View {
        if !reportList.isEmpty {
            List(reportList) { target in
                NavigationLink(value: target) {
                    Text(target.name?[0] ?? target.defaultName)
                }
            }.tag(targetTab).listStyle(.inset)
        } else {
            VStack {
                Spacer()
                Text("No \(targetTab.rawValue) :/")
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }.tag(targetTab)
        }
    }
}
