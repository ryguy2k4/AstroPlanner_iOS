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
        VStack {
            FilterDisclosureGroup("Catalog Selection") {
                SelectableList(selection: $viewModel.catalogSelection)
                    .scaledToFit()
            }
            FilterDisclosureGroup("Type Filter") {
                SelectableList(selection: $viewModel.typeSelection)
                    .scaledToFit()
            }

            Spacer()
        }
        .padding()
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
