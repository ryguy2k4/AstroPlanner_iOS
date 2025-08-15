//
//  TopTenTabView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 2/17/23.
//

import SwiftUI
import DeepSkyCore

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
struct TopTenTabView: View {
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
        .tabViewStyle(.page(indexDisplayMode: .never))
        .scrollDisabled(true)
        .padding(.vertical)
        .frame(minHeight: 500)
    }
}

fileprivate struct TopTenListView: View {
    let reportList: [DeepSkyTarget]
    let targetTab: TargetTab
    
    var body: some View {
        if !reportList.isEmpty {
            List(reportList) { target in
                NavigationLink(value: target) {
                    Text(target.defaultName)
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

