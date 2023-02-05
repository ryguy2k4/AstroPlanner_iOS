//
//  ConfigSection.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/15/22.
//

import SwiftUI

/**
 A variant of the Section view that  consolidates the header, footer, and headerProminance modifier into a cleaner arrangement
 - Parameter header: The Section header
 - Parameter footer: The Section footer
 - Parameter prominentHeader: Makes the header bigger
 - Parameter content: The content within the Section
 */
struct ConfigSection<Content: View>: View {
    private let content: Content
    private let header: String
    private let footer: String
    private let prominentHeader: Bool
    var headerToggle: Binding<Bool>?
    
    init(header: String = "", headerToggle: Binding<Bool>? = nil, footer: String = "", prominentHeader: Bool = true, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.header = header
        self.footer = footer
        self.prominentHeader = prominentHeader
        self.headerToggle = headerToggle
    }
    
    var body: some View {
        Section() {
            content
        } header: {
            HStack {
                Text(header)
                if let headerToggle = headerToggle {
                    Toggle("", isOn: headerToggle)
                }
            }
        } footer: {
            Text(footer)
        }
        .headerProminence(prominentHeader ? .increased : .standard)
    }
}
