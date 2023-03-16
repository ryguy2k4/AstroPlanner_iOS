//
//  TopFiveView.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 3/16/23.
//

import SwiftUI

/**
 This View is a subview of DailyReportView that displays the topThree as defined within the report.
 */
struct TopFiveView: View {
    @EnvironmentObject var location: SavedLocation
    @EnvironmentObject var targetSettings: TargetSettings
    let report: DailyReport
    
    var body: some View {
        VStack {
            Text("Top Five Overall")
                .fontWeight(.bold)
            TabView {
                ForEach(report.topFive, id: \.id) { target in
                    NavigationLink(value: target) {
                        ZStack {
                            Image(target.image?.source.fileName ?? "\(target.type)")
                                .resizable()
                                .cornerRadius(12)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 368, height: 207)
                            VStack {
                                Text(target.name?[0] ?? target.defaultName)
                                    .padding(2)
                                    .background(.gray.opacity(0.8), in: Rectangle())
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(4)
                        }
                    }
                }
            }
            .frame(width: 368, height: 207)
            .tabViewStyle(.page)
        }
    }
}
