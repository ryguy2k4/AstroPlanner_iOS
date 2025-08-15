//
//  SelectableList.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/15/22.
//

import SwiftUI
import DeepSkyCore

/**
 Creates a list from all the cases of an enum, and allows selection of each case to be saved in a binding
 - Parameter selection: A binding to an array that holds the selected cases of the generic enum
 */
struct SelectableList<T: Filter>: View {
    @Binding var selection: Set<T>
    var body: some View {
        List {
            Section {
                ForEach(T.allCases, id: \.self) { item in
                    Button() {
                        // toggle item selection
                        if selection.contains(item) {
                            selection.remove(item)
                        } else {
                            selection.insert(item)
                        }
                    } label: {
                        HStack {
                            if selection.contains(item) {
                                Image(systemName: "checkmark.circle")
                            } else {
                                Image(systemName: "circle")
                            }
                            Text(item.rawValue)
                                .foregroundColor(.primary)
                        }
                    }
                }
            } header: {
                Text(T.name)
            }
        }
    }
}
