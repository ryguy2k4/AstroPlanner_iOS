//
//  AboutView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/17/22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            Text("Made by Ryan Sponzilli")
            Link("YouTube", destination: URL(string: "https://www.youtube.com/@ryansponzilli")!)
            Link("Instagram", destination: URL(string: "https://www.instagram.com/ryansponzilli_astro/")!)
            Spacer()
            Text("API Attributions:")
            Text("sunrise-sunset.org")
            Text("aa.usno.navy.mil")
            Spacer()
            
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
