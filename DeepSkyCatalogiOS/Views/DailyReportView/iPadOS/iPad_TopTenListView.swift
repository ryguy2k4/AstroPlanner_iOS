//
//  iPad_TopTenView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/27/23.
//

import SwiftUI

struct iPad_TopTenListView: View {
    let reportList: [DeepSkyTarget]
    let targetTab: TargetTab
    var body: some View {
        VStack {
            Text(targetTab.rawValue)
                .fontWeight(.bold)
            if !reportList.isEmpty {
                List(reportList) { target in
                    NavigationLink(value: target) {
                        Text(target.name?[0] ?? target.defaultName)
                    }
                }
                .tag(targetTab)
                .listStyle(.inset)
            } else {
                List {
                    Text("No \(targetTab.rawValue) :/")
                }
            }
        }
        .frame(minWidth: 200, minHeight: 800, alignment: .center)
    }
}
