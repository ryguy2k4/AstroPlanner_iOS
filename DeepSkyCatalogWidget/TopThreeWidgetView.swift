//
//  TopThreeWidgetView.swift
//  DeepSkyCatalogWidgetExtension
//
//  Created by Ryan Sponzilli on 1/3/23.
//

import SwiftUI
import WidgetKit

struct TopThreeWidgetView : View {
    var entry: TopThreeEntry

    var body: some View {
        VStack {
            ForEach(entry.topThree) { target in
                HStack {
                    Image(target.image.source.fileName)
                        .resizable()
                        .scaledToFit()
                    Text(target.name.first!)
                    Spacer()
                }
            }
        }
        .padding(20)
        
    }
}

struct TopThreeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let topThree = [DeepSkyTargetList.allTargets[0], DeepSkyTargetList.allTargets[1], DeepSkyTargetList.allTargets[2]]
        TopThreeWidgetView(entry: TopThreeEntry(date: Date(), topThree: topThree))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}


