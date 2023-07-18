//
//  ImageViewer.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/11/23.
//

import SwiftUI

struct ImageViewer: View {
    @EnvironmentObject var networkManager: NetworkManager
    let image: String
    @State var imageData: APODImageData? = nil

    var body: some View {
        VStack {
            if let imageData = imageData {
                ZoomableScrollView {
                    AsyncImage(url: URL(string: imageData.hdurl)) { HDImage in
                        HDImage
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal)
                        HStack {
                            Spacer()
                            Text("HD Loaded")
                                .padding()
                                .fontWeight(.bold)
                        }
                    } placeholder: {
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal)
                        HStack {
                            Spacer()
                            ProgressView()
                            Text("HD Loading")
                                .padding()
                                .fontWeight(.bold)
                        }
                    }
                }
            } else {
                ZoomableScrollView {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
            }
        }
        .task {
            do {
                imageData = try await networkManager.getImageData(for: image.replacingOccurrences(of: "apod_", with: ""))
            } catch {
               //print(error.localizedDescription)
            }
        }
    }
}
