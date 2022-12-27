//
//  FilterConstellationView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/22/22.
//

import SwiftUI

struct FilterConstellationView: View {
    @ObservedObject var viewModel: CatalogViewModel
    
    var body: some View {
        Text("Filter by Constellation")
        List {
            ForEach(Constellation.allCases, id: \.self) { item in
                MultipleSelectionRow(title: item.rawValue, isSelected: viewModel.constellationSelection.contains(item)) {
                    if viewModel.constellationSelection.contains(item) {
                        viewModel.constellationSelection.removeAll(where: { $0 == item })
                    }
                    else {
                        viewModel.constellationSelection.append(item)
                    }
                }
            }
        }
        .onDisappear() {
            viewModel.refreshList()
        }
    }
}
