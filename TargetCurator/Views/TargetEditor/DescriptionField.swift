//
//  DescriptionField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 7/17/23.
//

import SwiftUI

struct DescriptionField: View {
    @Binding var description: String
    @Binding var wikipediaURL: String?
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                if #available(macOS 13.0, *) {
                    TextField("", text: $description, axis: .vertical)
                } else {
                    // Fallback on earlier versions
                }
                HStack {
                    let urlbinding = Binding(
                        get: { wikipediaURL ?? "" },
                        set: { wikipediaURL = $0}
                    )
                    Text("Wikipedia Link: ")
                    if wikipediaURL != nil {
                        Button("Remove URL") {
                            wikipediaURL = nil
                        }
                        TextField("", text: urlbinding)
                    } else {
                        Button("Add URL") {
                            wikipediaURL = "https://wikipedia.org"
                        }
                    }
                    if let link = wikipediaURL {
                        Link(destination: URL(string: link)!) {
                            Label("Wikipedia", systemImage: "arrow.up.forward.square")
                        }
                    }
                }
            }
        } header: {
            Text("Description")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}
