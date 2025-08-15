//
//  TopFiveView.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 3/16/23.
//

import SwiftUI
import DeepSkyCore

/**
 This View is a subview of DailyReportView that displays the topThree as defined within the report.
 */
struct TopFiveView: View {
    let report: DailyReport
    
    var body: some View {
        TabView {
            ForEach(report.topFive, id: \.id) { target in
                NavigationLink(value: target) {
                    VStack {
                        Text(target.defaultName)
                            .fontWeight(.thin)
                            .foregroundColor(.primary)
                        Image(target.image?.filename ?? "\(target.type)")
                            .resizable()
                            .cornerRadius(12)
                            .scaledToFit()
                            .padding(4)
                    }
                }
            }
        }
        .frame(width: 384, height: 246)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
