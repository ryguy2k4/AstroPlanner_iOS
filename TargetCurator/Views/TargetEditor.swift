//
//  TargetEditor.swift
//  DeepSkyTargetHelper
//
//  Created by Ryan Sponzilli on 1/15/23.
//

import SwiftUI

struct TargetEditor: View {
    @Binding var target: DeepSkyTarget
    @State var names: [String]?
    @State var designation: [DeepSkyTarget.Designation]
    @State var subDesignations: [DeepSkyTarget.Designation]
    @State var subTargets: [String]
    @State var image: DeepSkyTarget.TargetImage?
    @State var description: String
    @State var wikipediaURL: String?
    @State var type: TargetType
    @State var constellation: Constellation
    @State var ra: Double
    @State var dec: Double
    @State var arcLength: Double
    @State var arcWidth: Double
    @State var apparentMag: Double?
    
    init(target: Binding<DeepSkyTarget>) {
        self._target = target
        self._names = State(initialValue: target.wrappedValue.name)
        self._designation = State(initialValue: target.wrappedValue.designation)
        self._subDesignations = State(initialValue: target.wrappedValue.subDesignations)
        self._subTargets = State(initialValue: target.wrappedValue.subTargets.map(\.uuidString))
        self._image = State(initialValue: target.wrappedValue.image)
        self._description = State(initialValue: target.wrappedValue.description)
        self._wikipediaURL = State(initialValue: target.wrappedValue.wikipediaURL?.absoluteString)
        self._type = State(initialValue: target.wrappedValue.type)
        self._constellation = State(initialValue: target.wrappedValue.constellation)
        self._ra = State(initialValue: target.wrappedValue.ra)
        self._dec = State(initialValue: target.wrappedValue.dec)
        self._arcLength = State(initialValue: target.wrappedValue.arcLength)
        self._arcWidth = State(initialValue: target.wrappedValue.arcWidth)
        self._apparentMag = State(initialValue: target.wrappedValue.apparentMag)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(target.id.uuidString)
                    .font(.title)
                    .textSelection(.enabled)
                VStack(alignment: .leading) {
                    NamesField(names: $names, id: target.id.uuidString)
                    DesignationsField(designation: $designation, sub: false)
                    DesignationsField(designation: $subDesignations, sub: true)
                    SubTargets(subTargets: $subTargets, subDesignations: $subDesignations)
                    CoordinatesField(ra: $ra, dec: $dec, subTargets: subTargets)
                    TypesField(type: $type)
                }
                VStack(alignment: .leading) {
                    ConstellationField(constellation: $constellation)
                    DescriptionField(description: $description, wikipediaURL: $wikipediaURL)
                    ImageField(image: $image, target: target)
                    SizeField(arcLength: $arcLength, arcWidth: $arcWidth)
                    MagnitudeField(magnitude: $apparentMag)
                }
            }
        }
        .padding()
        .frame(minWidth: 600, maxWidth: 2400, minHeight: 400,  maxHeight: 1600)
        .onDisappear() {
            target.name = names
            target.designation = designation
            target.subDesignations = subDesignations
            target.subTargets = subTargets.compactMap({UUID(uuidString: $0)})
            target.image = image
            target.description = description
            if let wikipediaURL = wikipediaURL {
                target.wikipediaURL = URL(string: wikipediaURL)
            } else {
                target.wikipediaURL = nil
            }
            target.type = type
            target.constellation = constellation
            target.ra = ra
            target.dec = dec
            target.arcLength = arcLength
            target.arcWidth = arcWidth
            target.apparentMag = apparentMag
        }
    }
}

struct SubTargets: View {
    @Binding var subTargets: [String]
    @Binding var subDesignations: [DeepSkyTarget.Designation]
    @State var isPopover = false
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        subTargets.append(.init())
                    } label: {
                        Label("Add Sub Target", systemImage: "plus.circle")
                    }
                    Button {
                        var subs: Set<DeepSkyTarget.Designation> = []
                        for item in subTargets {
                            let target = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == item})!
                            subs.formUnion(target.designation)
                            subs.formUnion(target.subDesignations)
                        }
                        subDesignations = Array(subs)
                    } label: {
                        Label("Merge Sub-Designations", systemImage: "arrow.triangle.merge")
                    }
                }
                ForEach(subTargets.indices, id: \.self) { index in
                    HStack {
                        Button {
                            subTargets.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                        }

                        if let target = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == subTargets[index]}) {
                            Text(target.defaultName)
                        } else {
                            Text("No Match")
                                .foregroundColor(.red)
                        }
                        TargetIDSearchField(searchText: $subTargets[index])
                    }
                }
            }
        } header: {
            Text("Sub Targets")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}

struct NamesField: View {
    @Binding var names: [String]?
    let id: String
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Button {
                    if names != nil {
                        names!.append("")
                    } else {
                        names = [""]
                    }
                } label: {
                    Label("Add Name", systemImage: "plus.circle")
                }
                if names != nil {
                    ForEach(0..<names!.count, id: \.self) { index in
                        HStack {
                            Button {
                                names!.remove(at: index)
                                if names!.isEmpty {
                                    names = nil
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            if let unwrappedNames = Binding($names) {
                                TextField("Name:", text: unwrappedNames[index])
                            }
                        }
                    }
                }
            }
        } header: {
            Text("Names")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}

struct DesignationsField: View {
    @Binding var designation: [DeepSkyTarget.Designation]
    let sub: Bool
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Button {
                    designation.append(DeepSkyTarget.Designation(catalog: .ngc, number: 0))
                } label: {
                    Label("Add Designation", systemImage: "plus.circle")
                }
                ForEach(0..<designation.count, id: \.self) { index in
                    HStack {
                        Button {
                            designation.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        
                        Picker("", selection: $designation[index].catalog) {
                            ForEach(TargetCatalog.allCases) { catalog in
                                Text(catalog.rawValue)
                            }
                        }
                        TextField("", value: $designation[index].number, format: .number)
                    }
                }
            }
        } header: {
            Text(sub ? "Sub Designations" : "Designations")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}

struct DescriptionField: View {
    @Binding var description: String
    @Binding var wikipediaURL: String?
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                if #available(macOS 13.0, *) {
                    TextField("", text: $description, axis: .vertical)
                } else {
                    // Fallback on earlier versions
                }
                HStack {
                    let urlbinding = Binding(
                        get: { wikipediaURL ?? "" },
                        set: { wikipediaURL = $0}
                    )
                    Text("Wikipedia Link: ")
                    if wikipediaURL != nil {
                        Button("Remove URL") {
                            wikipediaURL = nil
                        }
                        TextField("", text: urlbinding)
                    } else {
                        Button("Add URL") {
                            wikipediaURL = "https://wikipedia.org"
                        }
                    }
                    if let link = wikipediaURL {
                        Link(destination: URL(string: link)!) {
                            Label("Wikipedia", systemImage: "arrow.up.forward.square")
                        }
                    }
                }
            }
        } header: {
            Text("Description")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}

struct TypesField: View {
    @Binding var type: TargetType

    var body: some View {
        Section {
            Picker("", selection: $type) {
                ForEach(TargetType.allCases) { type in
                    Text(type.rawValue)
                }
            }
        } header: {
            Text("Type")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}

struct ConstellationField: View {
    @Binding var constellation: Constellation
    var body: some View {
        Section {
            Picker("", selection: $constellation) {
                ForEach(Constellation.allCases) { type in
                    Text(type.rawValue)
                }
            }
        } header: {
            Text("Constellation")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}

struct CoordinatesField: View {
    @Binding var ra: Double
    @Binding var dec: Double
    let subTargets: [String]
    var body: some View {
        Section {
            HStack {
                Button("Center of Sub-Targets") {
                    ra = {
                        var sum = 0.0
                        for id in subTargets {
                            sum += DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == id})!.ra
                        }
                        return sum / Double(subTargets.count)
                    }()
                    dec = {
                        var sum = 0.0
                        for id in subTargets {
                            sum += DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == id})!.dec
                        }
                        return sum / Double(subTargets.count)
                    }()
                }
                Text("Ra:")
                TextField("Ra:", value: $ra, format: .number)
                Text("Dec:")
                TextField("Dec: ", value: $dec, format: .number)
            }
        } header: {
            Text("Coordinates")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}

struct SizeField: View {
    @Binding var arcLength: Double
    @Binding var arcWidth: Double
    var body: some View {
        Section {
            HStack {
                Text("Length:")
                TextField("Length:", value: $arcLength, format: .number)
                Text("Width:")
                TextField("Width: ", value: $arcWidth, format: .number)
            }
        } header: {
            Text("Size")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}

struct MagnitudeField: View {
    @Binding var magnitude: Double?
    var body: some View {
        Section {
            HStack {
                Text("Magnitude:")
                TextField("Magnitude:", value: $magnitude, format: .number)
            }
        } header: {
            Text("Magnitude")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}
