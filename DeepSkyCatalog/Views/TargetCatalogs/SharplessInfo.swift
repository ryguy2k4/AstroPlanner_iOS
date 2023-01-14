//
//  SharplessInfo.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/13/23.
//

import SwiftUI

struct SharplessInfo: View {
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("Sharpless Catalog")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("313 Objects")
                    .font(.headline)
            }
            Text("The Sharpless Catalog")
                .padding()
            CatalogList(catalog: .sh2)
        }
    }
}
