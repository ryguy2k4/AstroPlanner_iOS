//
//  ContentView.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 1/14/23.
//

import SwiftUI

struct TargetCuratorView: View {
    @State var objects = DeepSkyTargetList.allTargets
    @State var objectIndex: Int?
    var body: some View {
        NavigationSplitView {
            VStack {
                Text("\(objectIndex ?? .zero)")
                Text("Objects")
                    .font(.title)
                HStack {
                    NavigationLink {
                        Button("Insert New Object") {
                            objects.insert(DeepSkyTarget(id: UUID(), name: nil, designation: [], subDesignations: [], subTargets: [], image: nil, description: "", wikipediaURL: URL(string: "https://wikipedia.org")!, type: .HIIRegion, constellation: .andromeda, ra: 0, dec: 0, arcLength: 0, arcWidth: 0, apparentMag: nil), at: objectIndex! + 1)
                        }
                    } label: {
                        Text("Insert Object")
                    }
                    NavigationLink {
                        Button("Delete Selected Object") {
                            objects.append(DeepSkyTarget(id: UUID(), name: nil, designation: [], subDesignations: [], subTargets: [], image: nil, description: "", wikipediaURL: URL(string: "https://wikipedia.org")!, type: .HIIRegion, constellation: .andromeda, ra: 0, dec: 0, arcLength: 0, arcWidth: 0, apparentMag: nil))
                            objects.remove(at: objectIndex!)
                        }
                    } label: {
                        Text("Delete Object")
                    }
                }
                List(objects.indices, id: \.self, selection: $objectIndex) { index in
                    TargetCell(target: objects[index])
                        .tag(index)
                }
            }
        } detail: {
            if let objectIndex = objectIndex {
                TargetEditor(target: $objects[objectIndex])
                    .navigationSplitViewColumnWidth(min: 800, ideal: 800)
                    .id(objects[objectIndex].id)
            } else {
                ContentUnavailableView("Select a Target", systemImage: "hurricane")
            }
            
        }
        .frame(minWidth: 600, maxWidth: 2400, minHeight: 400,  maxHeight: 1600)
        .toolbar {
            Button {
                DeepSkyTargetList.exportObjects(list: objects)
            } label: {
                Image(systemName: "square.and.arrow.down")
            }.help("Save Target List")
        }
    }
}

private struct TargetCell: View {
    var target: DeepSkyTarget
    
    var body: some View {
        HStack {
            Image(target.image?.filename ?? "\(target.type)")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 70)
                .cornerRadius(4)
            VStack(alignment: .leading) {
                Text(target.defaultName)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundColor(target.apparentMag == 20 ? .red : .primary)
                ForEach(target.designation, id: \.hashValue) { designation in
                    HStack {
                        Text(designation.catalog.rawValue)
                        Text("\(designation.number)")
                    }
                }
            }
        }
    }
}

private struct SearchBar: View {
    @Binding var searchText: String
    var updateAction: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("lightGray"))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchText)
                    .onSubmit(updateAction)
            }
            .foregroundColor(.black)
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}
