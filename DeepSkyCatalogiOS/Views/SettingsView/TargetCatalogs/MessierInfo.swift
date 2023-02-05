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
            Text("The Messier catalog was created by Charles Messier. Messier was only interested in finding comets, so he compiled this list of 110 non-comet objects that frustrated him.")
                .padding()
            CatalogList(catalog: .messier)
        }
    }
}
