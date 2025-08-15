//
//  iPad_TopFiveView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/27/23.
//

import SwiftUI
import DeepSkyCore

struct iPad_TopFiveView: View {
    let report: DailyReport
    var body: some View {
        HStack {
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
    }
}
