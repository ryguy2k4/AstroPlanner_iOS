//
//  FilterTypeView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/22/22.
//

import SwiftUI

struct FilterTypeView: View {
    @ObservedObject var viewModel: CatalogViewModel
    
    var body: some View {
        Text("Filter by Type")
        List {
            ForEach(DSOType.allCases, id: \.self) { item in
                MultipleSelectionRow(title: item.rawValue, isSelected: viewModel.typeSelection.contains(item)) {
                    if viewModel.typeSelection.contains(item) {
                        viewModel.typeSelection.removeAll(where: { $0 == item })
                    }
                    else {
                        viewModel.typeSelection.append(item)
                    }
                }
            }
        }
        .onDisappear() {
            viewModel.refreshList()
        }
    }
}
