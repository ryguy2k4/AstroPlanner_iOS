//
//  Mac_AboutView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import SwiftUI
import WeatherKit

struct Mac_AboutView: View {
    @State var attribution: WeatherAttribution? = nil
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Text("Made by Ryan Sponzilli")
                        .font(.title2)
                        .fontWeight(.bold)
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "play.circle.fill")
                            Link("YouTube", destination: URL(string: "https://www.youtube.com/@ryansponzilli")!)
                        }
                        .buttonStyle(.bordered)
                        Button(action: {}) {
                            Image(systemName: "camera.circle.fill")
                            Link("Instagram", destination: URL(string: "https://www.instagram.com/ryansponzilli_astro/")!)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                Text("The core idea behind this app is to make it easy to filter through a catalog of targets or use an algorithm that chooses the best target for a given night")
                    .multilineTextAlignment(.center)
                    .fontWeight(.medium)
                VStack(spacing: 10) {
                    Text("Features Coming Soon:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Favorites, Custom Horizons, Target Framing Overlays, User-Submitted Photos, Journal of Previously Imaged Targets, More Targets, and Planetary Targets")
                        .multilineTextAlignment(.center)
                }
                Text("This app is fairly new, so bugs and issues are bound to be found. If you find any, feel free to contact me via instagram (@ryansponzilli_astro) It is my intention to ensure that this app is worth its price.")
                    .multilineTextAlignment(.center)
                VStack(spacing: 10) {
                    Text("Attributions:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Link("sunrise-sunset.org", destination: URL(string: "https://sunrise-sunset.org/")!)
                    if let attribution = attribution {
                        Link(destination: attribution.legalPageURL) {
                            AsyncImage(url: colorScheme != .dark ? attribution.combinedMarkLightURL : attribution.combinedMarkDarkURL) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 15)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
                Spacer()
                
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 25)
            .task {
                attribution = try? await WeatherService().attribution
            }
        }
    }
}
