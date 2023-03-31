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
                    ImageField(image: $image)
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
                            let target = DeepSkyTargetList.objects.first(where: {$0.id.uuidString == item})!
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

                        if let target = DeepSkyTargetList.objects.first(where: {$0.id.uuidString == subTargets[index]}) {
                            Text(target.name?.first ?? target.defaultName)
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
                            sum += DeepSkyTargetList.objects.first(where: {$0.id.uuidString == id})!.ra
                        }
                        return sum / Double(subTargets.count)
                    }()
                    dec = {
                        var sum = 0.0
                        for id in subTargets {
                            sum += DeepSkyTargetList.objects.first(where: {$0.id.uuidString == id})!.dec
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

struct ImageField: View {
    @Binding var image: DeepSkyTarget.TargetImage?
    @State var id: String
    @State var isCopyrightInfo: Bool
    
    @State var copyrighted: Bool
    
    init(image: Binding<DeepSkyTarget.TargetImage?>) {
        self._image = image
        self.id = {
            switch image.wrappedValue?.source {
            case .local(fileName: let filename):
                return filename
            case .apod(id: let id, copyrighted: _):
                return id
            case nil:
                return ""
            }
        }()
        self.isCopyrightInfo = image.wrappedValue?.credit != nil
        self.copyrighted = {
            switch image.wrappedValue?.source {
            case .local(fileName: _):
                return false
            case .apod(id: _, copyrighted: let copyrighted):
                return copyrighted
            case nil:
                return false
            }
        }()
    }
    var body: some View {
        Section {
            HStack {
                // Pick type of image and image ID
                if let unwrappedImage = Binding($image) {
                    Button("No Image") {
                        image = nil
                    }
                    Picker("", selection: unwrappedImage.source) {
                        Text("APOD").tag(DeepSkyTarget.TargetImage.ImageSource.apod(id: id, copyrighted: copyrighted))
                        Text("Local").tag(DeepSkyTarget.TargetImage.ImageSource.local(fileName: id))
                    }
                    TextField("ID:", text: $id)
                    Toggle("Copyrighted:", isOn: $copyrighted)
                    TextField("Credit:", text: unwrappedImage.credit)
                    
                    // Button to retrieve APOD Info
                    Button("Get APOD Info") {
                        Task {
                            let image = try? await NetworkManager.shared.getImageData(for: id)
                            
                            if let image = image {
                                self.image!.credit = image.copyright ?? "CREDIT"
                                isCopyrightInfo = image.copyright != nil
                                
                                let fileURL = URL(fileURLWithPath: "/Users/ryansponzilli/Documents/DeepSkyCatalog Python Scripts/image script/apodurls.txt")
                                    let text = "\(id);\(image.url)\n"
                                    
                                if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                                    defer {
                                        fileHandle.closeFile()
                                    }
                                    fileHandle.seekToEndOfFile()
                                    fileHandle.write(text.data(using: .utf8)!)
                                }
                            }
                        }
                    }
                } else {
                    Button("Add Image") {
                        image = DeepSkyTarget.TargetImage(source: .apod(id: "APOD", copyrighted: false), credit: "CREDIT")
                    }
                }
            }
        } header: {
            HStack {
                Text("Image")
                if let url = image?.source.url {
                    Link(destination: url) {
                        Image(systemName: "arrow.up.forward.square")
                    }
                }
            }
            .font(.title3)
            .fontWeight(.bold)
            .padding(.top)
        }
    }
}

/*
 struct TypesField: View {
     @Binding var type: TargetType
     @State var dependent: Bool = false
     @State var group: [String] = []
     @State var single: String = "00000000-0000-0000-0000-000000000000"
     @State var selection: Int = 0
     
     init(type: Binding<TargetType>) {
         self._type = type
         switch type.wrappedValue {
         case .emissionNebula(let dependent), .reflectionNebula(let dependent), .darkNebula(let dependent), .planetaryNebula(let dependent), .supernovaRemnant(let dependent):
             self._dependent = State(initialValue: dependent)
             self._selection = State(initialValue: 0)
         case .ellipticalGalaxy(let dependent), .spiralGalaxy(let dependent), .irregularGalaxy(let dependent):
             self._dependent = State(initialValue: dependent)
             self._selection = State(initialValue: 1)
         case .openStarCluster(let dependent), .globularStarCluster(let dependent), .starCloud(let dependent), .asterism(let dependent):
             self._dependent = State(initialValue: dependent)
             self._selection = State(initialValue: 2)
         case .galaxyGroup(galaxies: let group), .interactingGalaxies(galaxies: let group), .componentGrouping(components: let group):
             self._group = State(initialValue: group.map({$0.uuidString}))
             self._selection = State(initialValue: 3)
         case .nebulaWithAssociatedCluster(cluster: let object):
             self._single = State(initialValue: object.uuidString)
             self._selection = State(initialValue: 3)
         }
     }
     var body: some View {
         Section {
             Picker("", selection: $selection) {
                 Text("Nebula").tag(0)
                 Text("Galaxy").tag(1)
                 Text("Star Cluster").tag(2)
                 Text("Plural").tag(3)
             }
             if selection == 0 {
                 Picker("", selection: $type) {
                     Text("Emission Nebula").tag(TargetType.emissionNebula(dependent: dependent))
                     Text("Reflection Nebula").tag(TargetType.reflectionNebula(dependent: dependent))
                     Text("Dark Nebula").tag(TargetType.darkNebula(dependent: dependent))
                     Text("Planetary Nebula").tag(TargetType.planetaryNebula(dependent: dependent))
                     Text("Supernova Remnant").tag(TargetType.supernovaRemnant(dependent: dependent))
                 }
             } else if selection == 1 {
                 Picker("", selection: $type) {
                     Text("Elliptical Galaxy").tag(TargetType.ellipticalGalaxy(dependent: dependent))
                     Text("Spiral Galaxy").tag(TargetType.spiralGalaxy(dependent: dependent))
                     Text("Irregular Galaxy").tag(TargetType.irregularGalaxy(dependent: dependent))
                 }
             } else if selection == 2 {
                 Picker("", selection: $type) {
                     Text("Open Star Cluster").tag(TargetType.openStarCluster(dependent: dependent))
                     Text("Globular Star Cluster").tag(TargetType.globularStarCluster(dependent: dependent))
                     Text("Star Cloud").tag(TargetType.starCloud(dependent: dependent))
                     Text("Asterism").tag(TargetType.asterism(dependent: dependent))
                 }
             } else if selection == 3 {
                 Picker("", selection: $type) {
                     Text("Galaxy Group").tag(TargetType.galaxyGroup(galaxies: group.map({UUID(uuidString: $0)!})))
                     Text("Interacting Galaxies").tag(TargetType.interactingGalaxies(galaxies: group.map({UUID(uuidString: $0)!})))
                     Text("Nebula With Associated Cluster").tag(TargetType.nebulaWithAssociatedCluster(cluster: UUID(uuidString: single)!))
                     Text("Grouping of Components").tag(TargetType.componentGrouping(components: group.map({UUID(uuidString: $0)!})))
                 }
             }
             
             switch type.unassociatedCase {
             case .emissionNebula, .reflectionNebula, .darkNebula, .planetaryNebula, .supernovaRemnant, .ellipticalGalaxy, .spiralGalaxy, .irregularGalaxy, .openStarCluster, .globularStarCluster, .starCloud, .asterism:
                 Toggle("Dependent", isOn: $dependent)
             case .galaxyGroup, .interactingGalaxies, .componentGrouping:
                 HStack {
                     Button("Add Object", action: { group.append("00000000-0000-0000-0000-000000000000") })
                     ForEach($group, id: \.self) { id in
                         VStack {
                             HStack {
                                 Button {
                                     group.removeAll(where: {$0 == id.wrappedValue})
                                 } label: {
                                     Image(systemName: "minus.circle")
                                 }
                                 TextField("", text: id)
                             }
                             if let dst = DeepSkyTargetList.objects.first(where: {$0.id.uuidString == id.wrappedValue}) {
                                 Text(dst.name?.first ?? dst.defaultName)
                             } else {
                                 Text("No Match!")
                                     .foregroundColor(.red)
                             }
                             
                         }
                     }
                 }
             case .nebulaWithAssociatedCluster:
                 VStack {
                     TextField("", text: $single)
                     if let dst = DeepSkyTargetList.objects.first(where: {$0.id.uuidString == single}) {
                         Text(dst.name?.first ?? dst.defaultName)
                     } else {
                         Text("No Match!")
                             .foregroundColor(.red)
                     }
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
 */
