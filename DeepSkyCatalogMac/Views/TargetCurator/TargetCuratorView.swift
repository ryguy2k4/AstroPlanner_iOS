//
//  ContentView.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 1/14/23.
//

import SwiftUI

struct TargetCuratorView: View {
    @State var objects = DeepSkyTargetList.allTargets
    @State var objectIndex = 0
    var body: some View {
        NavigationView {
            VStack {
                Text("\(objectIndex)")
                Text("Objects")
                    .font(.title)
                HStack {
                    NavigationLink {
                        Button("Insert New Object") {
                            objects.insert(DeepSkyTarget(id: UUID(), name: nil, designation: [], subDesignations: [], subTargets: [], image: nil, description: "", wikipediaURL: URL(string: "https://wikipedia.org")!, type: .HIIRegion, constellation: .andromeda, ra: 0, dec: 0, arcLength: 0, arcWidth: 0, apparentMag: nil), at: objectIndex + 1)
                        }
                    } label: {
                        Text("Insert Object")
                    }
                    NavigationLink {
                        Button("Delete Selected Object") {
                            objects.append(DeepSkyTarget(id: UUID(), name: nil, designation: [], subDesignations: [], subTargets: [], image: nil, description: "", wikipediaURL: URL(string: "https://wikipedia.org")!, type: .HIIRegion, constellation: .andromeda, ra: 0, dec: 0, arcLength: 0, arcWidth: 0, apparentMag: nil))
                            objects.remove(at: objectIndex)
                        }
                    } label: {
                        Text("Delete Object")
                    }
                }
                List(objects.indices, id: \.self, selection: $objectIndex) { index in
                    NavigationLink {
                        TargetEditor(target: $objects[index])
                    } label: {
                        TargetCell(target: objects[index])
                    }
                }
            }
        }
        .frame(minWidth: 600, maxWidth: 2400, minHeight: 400,  maxHeight: 1600)
        .toolbar {
            Button("Save Lists") {
                DeepSkyTargetList.exportObjects(list: objects)
            }
        }
    }
}

private struct TargetCell: View {
    var target: DeepSkyTarget
    
    var body: some View {
        HStack {
            Image(target.image?.source.fileName ?? "\(target.type)")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 70)
                .cornerRadius(4)
            VStack(alignment: .leading) {
                Text(target.name?[0] ?? target.defaultName)
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
                .foregroundColor(Color("LightGray"))
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
