//
//  Mac_TopFiveView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/13/23.
//

import SwiftUI

/**
 This View is a subview of DailyReportView that displays the topThree as defined within the report.
 */
struct Mac_TopFiveView: View {
    let report: DailyReport
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(report.topFive, id: \.id) { target in
                    VStack {
                        Image(target.image?.source.fileName ?? "\(target.type)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 400)
                            .cornerRadius(12)
                        NavigationLink(value: target) {
                            VStack {
                                Text(target.name?[0] ?? target.defaultName)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
        }
    }
}
