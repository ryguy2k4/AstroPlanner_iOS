//
//  MessierInfo.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/12/23.
//

import SwiftUI

struct MessierInfo: View {
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
                ForEach(DeepSkyTargetList.allTargets.filteredByCatalog([.messier]).sortedByCatalog(descending: false, catalog: .messier)) { target in
                    HStack {
                        Text("M#")
                        Divider()
                        Text(target.name.first!)
                    }
                }
            }
        }
    }
}

struct MessierInfo_Previews: PreviewProvider {
    static var previews: some View {
        MessierInfo()
    }
}
