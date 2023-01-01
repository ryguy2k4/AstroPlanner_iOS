//
//  View.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/15/22.
//

import Foundation
import SwiftUI

/**
 Implements the custom view modifier FilterModal
 */
extension View {
    func filterModal<Content:View>(isPresented: Binding<Bool>, viewModel: CatalogViewModel, @ViewBuilder sheetContent: () -> Content) -> some View {
        modifier(FilterModal(isPresented: isPresented, viewModel: viewModel, sheetContent: sheetContent))
    }
}

/**
 Custom view modifier that displays a filter modal
 */
struct FilterModal<C: View>: ViewModifier {
    @ObservedObject var viewModel: CatalogViewModel
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @Environment(\.date) var date
    @Environment(\.data) var data
    let sheetContent: C
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, viewModel: CatalogViewModel, @ViewBuilder sheetContent: () -> C) {
        self.viewModel = viewModel
        self.sheetContent = sheetContent()
        self._isPresented = isPresented
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent
                    .onDisappear() {
                        viewModel.refreshList(sunData: data.sun)
                    }
                    .presentationDetents([.fraction(0.5), .fraction(0.8)])
            }
    }
}
