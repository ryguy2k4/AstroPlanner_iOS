//
//  View.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/15/22.
//

import Foundation
import SwiftUI
import UIKit

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

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
  private var content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  func makeUIView(context: Context) -> UIScrollView {
    // set up the UIScrollView
    let scrollView = UIScrollView()
    scrollView.delegate = context.coordinator  // for viewForZooming(in:)
    scrollView.maximumZoomScale = 20
    scrollView.minimumZoomScale = 1
    scrollView.bouncesZoom = true

    // create a UIHostingController to hold our SwiftUI content
    let hostedView = context.coordinator.hostingController.view!
    hostedView.translatesAutoresizingMaskIntoConstraints = true
    hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostedView.frame = scrollView.bounds
    scrollView.addSubview(hostedView)

    return scrollView
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(hostingController: UIHostingController(rootView: self.content))
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    // update the hosting controller's SwiftUI content
    context.coordinator.hostingController.rootView = self.content
    assert(context.coordinator.hostingController.view.superview == uiView)
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, UIScrollViewDelegate {
    var hostingController: UIHostingController<Content>

    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return hostingController.view
    }
  }
}
