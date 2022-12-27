//
//  FilterCatalog.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/20/22.
//

import SwiftUI

struct FilterCatalogView: View {
    @ObservedObject var viewModel: CatalogViewModel
    
    var body: some View {
        Text("Filter by Catalog")
        List {
            ForEach(DSOCatalog.allCases, id: \.self) { item in
                MultipleSelectionRow(title: item.rawValue, isSelected: viewModel.catalogSelection.contains(item)) {
                    if viewModel.catalogSelection.contains(item) {
                        viewModel.catalogSelection.removeAll(where: { $0 == item })
                    }
                    else {
                        viewModel.catalogSelection.append(item)
                    }
                }
            }
        }
        .onDisappear() {
            viewModel.refreshList()
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isSelected {
                    Image(systemName: "checkmark.circle")
                } else {
                    Image(systemName: "circle")
                }
                Text(title)
                    .foregroundColor(.primary)
             
            }
        }
    }
}
