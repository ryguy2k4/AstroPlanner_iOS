//
//  MessierInfo.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/12/23.
//

import SwiftUI

struct MessierInfo: View {
    // change this when I add a non-mutating filter method
    @State var messier = DeepSkyTargetList.allTargets
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("Messier Catalog")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("110 Objects")
                    .font(.headline)
            }
            Text("The Messier catalog was created by Charles Messier. Messier was only interested in finding comets, so he compiled this list of 108 non-comet objects that frustrated him.")
                .padding()
            List {
                ForEach(messier) { target in
                    Text(target.name.first!)
                }
            }
        }
        .onAppear() {
            messier.filter(byCatalogSelection: [.messier])
        }
    }
}

struct MessierInfo_Previews: PreviewProvider {
    static var previews: some View {
        MessierInfo()
    }
}
