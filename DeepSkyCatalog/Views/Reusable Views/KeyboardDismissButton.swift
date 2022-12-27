//
//  KeyboardDismissButton.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/26/22.
//

import SwiftUI

struct KeyboardDismissButton: ToolbarContent {
    @FocusState var isInputActive
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
                isInputActive = false
            }
        }
    }
}
