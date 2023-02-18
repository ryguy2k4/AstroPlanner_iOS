//
//  TopTenLists.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 2/17/23.
//

import SwiftUI

fileprivate enum TargetTab: String, Identifiable, CaseIterable {
    var id: Self { self }
    case nebulae = "Nebulae"
    case galaxies = "Galaxies"
    case starClusters = "Star Clusters"
}

/**
 This View is a TabView that uses a Segmented Picker to switch between tabs.
 Each Tab displays the 3 topFive arrays defined in the report.
 */
struct TopTenTabView: View {
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var targetSettings: TargetSettings
    let report: DailyReport
    
    @State private var tabSelection: TargetTab = .nebulae
    
    var body: some View {
        VStack {
            Text("Top Ten")
                .fontWeight(.bold)
            
            Picker("Tab", selection: $tabSelection) {
                ForEach(TargetTab.allCases) { tab in
                    Text(tab.rawValue)
                }
            }.pickerStyle(.segmented).padding(.horizontal, 16)
            
            TabView(selection: $tabSelection) {
                TopTenTab(reportList: report.topTenNebulae, targetTab: .nebulae)
                TopTenTab(reportList: report.topTenGalaxies, targetTab: .galaxies)
                TopTenTab(reportList: report.topTenStarClusters, targetTab: .starClusters)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .scrollDisabled(true)
        .padding(.vertical)
        .frame(minHeight: 500)
    }
}

fileprivate struct TopTenTab: View {
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
                Text("No \(targetTab.rawValue)")
                Spacer()
            }.tag(targetTab)
        }
    }
}

