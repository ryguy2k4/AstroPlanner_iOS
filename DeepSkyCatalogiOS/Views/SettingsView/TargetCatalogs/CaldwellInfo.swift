//
//  CaldwellInfo.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/13/23.
//

import SwiftUI

struct CaldwellInfo: View {
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("Caldwell Catalog")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("109 Objects")
                    .font(.headline)
            }
            Text("The Caldwell Catalog")
                .padding()
            CatalogList(catalog: .caldwell)
        }
    }
}
