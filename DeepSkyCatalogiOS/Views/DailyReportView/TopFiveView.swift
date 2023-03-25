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
    @EnvironmentObject var targetSettings: TargetSettings
    @State var currentTarget: DeepSkyTarget?
    let report: DailyReport
    
    var body: some View {
        VStack {
            Text("Top Five Overall")
                .font(.title2)
                .underline()
            TabView {
                ForEach(report.topFive, id: \.id) { target in
                    NavigationLink(value: target) {
                        Image(target.image?.source.fileName ?? "\(target.type)")
                            .resizable()
                            .cornerRadius(12)
                            .scaledToFit()
                            .padding(4)
                            .onAppear() {
                                currentTarget = target
                            }
                    }
                }
            }
            .frame(width: 384, height: 216)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            Text(currentTarget?.name?[0] ?? currentTarget?.defaultName ?? "loading")
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}
