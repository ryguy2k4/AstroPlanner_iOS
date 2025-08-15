//
//  ToolbarLogo.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 2/19/23.
//

import SwiftUI

struct ToolbarLogo: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Label("Astro Planner", systemImage: "hurricane")
                .fontWeight(.semibold)
                .font(.title3)
                .labelStyle(.titleAndIcon)
        }
    }
}
