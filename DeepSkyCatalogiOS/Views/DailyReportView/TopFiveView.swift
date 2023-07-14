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
    let report: DailyReport
    
    var body: some View {
        TabView {
            ForEach(report.topFive, id: \.id) { target in
                NavigationLink(value: target) {
                    VStack {
                        Text(target.name?[0] ?? target.defaultName)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Image(target.image?.source.fileName ?? "\(target.type)")
                            .resizable()
                            .cornerRadius(12)
                            .scaledToFit()
                            .padding(4)
                    }
                }
            }
        }
    }
}
