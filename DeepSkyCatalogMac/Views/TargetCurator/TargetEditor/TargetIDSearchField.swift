//
//  TargetIDSearchField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 2/14/23.
//

import SwiftUI

struct TargetIDSearchField: View {
    @Binding var searchText: String
    @State var isPopover: Bool = false
    var body: some View {
        TextField("", text: $searchText)
            .frame(width: 300)
            .onChange(of: searchText) {
                isPopover = true
            }
            .popover(isPresented: $isPopover) {
                
                // grab top 15 search results
                let suggestions: [DeepSkyTarget] = {
                    var list = DeepSkyTargetList.allTargets
                    list.filterBySearch(searchText)
                    list.removeLast(list.count > 15 ? list.count-15 : 0)
                    return list
                }()
                
                // list the search results
                VStack {
                    ForEach(suggestions) { suggestion in
                        Button {
                            searchText = suggestion.id.uuidString
                        } label: {
                            Text("\(suggestion.defaultName): \(suggestion.id)")
                        }

                    }
                }
            }
    }
}
