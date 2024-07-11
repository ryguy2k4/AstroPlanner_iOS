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
    @Binding var selection: DeepSkyTarget?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(report.topFive, id: \.id) { target in
                    VStack {
                        Image(target.image?.filename ?? "\(target.type)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 400)
                            .cornerRadius(12)
                            .border(target == selection ? Color.accentColor.opacity(0.5) : Color.clear, width: 10)
                    }
                    .onTapGesture {
                        if selection == target {
                            selection = nil
                        } else {
                            selection = target
                        }
                    }
                }
            }
        }
    }
}
