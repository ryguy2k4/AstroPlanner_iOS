//
//  EditAllFiltersView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/30/22.
//

import SwiftUI

struct EditAllFiltersView: View {
    @ObservedObject var viewModel: CatalogViewModel
//    @State private var isCatalogExpanded = false
//    @State private var isTypeExpanded = false
    var body: some View {
        NavigationStack {
            Form {
                ConfigSection(header: "Sort") {
                    Text("Sort Methods")
                }
                ConfigSection(header: "Filters") {
                    NavigationLink("Catalog Filter") {
                        SelectableList(selection: $viewModel.catalogSelection)
                    }
                    NavigationLink("Type Filter") {
                        SelectableList(selection: $viewModel.typeSelection)
                    }
                    NavigationLink("Constellation Filter") {
                        SelectableList(selection: $viewModel.constellationSelection)
                    }
                    NavigationLink("Magnitude Filter") {
                        MinMaxPicker(min: $viewModel.brightestMag, max: $viewModel.dimmestMag, maxTitle: "Brighter than", minTitle: "Dimmer than", placeValues: [.ones, .tenths])
                    }
                    NavigationLink("Size Filter") {
                        MinMaxPicker(min: $viewModel.minSize, max: $viewModel.maxSize, maxTitle: "Largest Size", minTitle: "Smallest Size", placeValues: [.hundreds, .tens, .ones])
                    }
                    NavigationLink("Visibility Score Filter") {
                        Form {
                            NumberPicker(num: $viewModel.minVisScore, placeValues: [.tenths, .hundredths])
                        }
                    }
                    NavigationLink("Meridian Score Filter") {
                        Form {
                            NumberPicker(num: $viewModel.minMerScore, placeValues: [.tenths, .hundredths])
                        }
                    }
                }
            }
        }
    }
}

private struct FilterDisclosureGroup<Content: View>: View {
    let content: Content
    let label: String
    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.label = label
    }
    var body: some View {
        DisclosureGroup {
            content
                .scaledToFit()
        } label: {
            Text(label)
                .foregroundColor(.primary)
        }

    }
}

//struct EditAllFiltersView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditAllFiltersView()
//    }
//}
