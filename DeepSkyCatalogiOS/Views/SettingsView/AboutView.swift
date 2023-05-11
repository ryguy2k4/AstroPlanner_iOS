//
//  AboutView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/17/22.
//

import SwiftUI
import WeatherKit

struct AboutView: View {
    @State var attribution: WeatherAttribution? = nil
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack() {
            Spacer()
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
            Spacer()
            Text("The core idea behind this app is to make it easy to filter through a catalog of targets or use an algorithm that chooses the best target for a given night")
                .multilineTextAlignment(.center)
            Spacer()
            Text("Features Coming Soon:")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Favorites, iMessage Sharing, Custom  Horizons, Target Framing Overlays, User-Submitted Photos, Journal of Previosuly Imaged Targets, More Targets, Support for Extreme Latitudes, and Planetary Targets")
                .multilineTextAlignment(.center)
            Spacer()
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
        .task {
            attribution = try? await WeatherService().attribution
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
