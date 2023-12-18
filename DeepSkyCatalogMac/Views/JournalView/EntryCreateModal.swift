//
//  EntryCreateModal.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/17/23.
//

import SwiftUI

struct EntryCreateModal: View {
    @State var ninaImagePlanURL: URL? = nil
    @State var ninaLogFileURL: URL? = nil
    @State var fitsURLs: [URL]? = nil
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .frame(minWidth: 1200, maxWidth: 2400, minHeight: 800,  maxHeight: 1600)
    }
}
