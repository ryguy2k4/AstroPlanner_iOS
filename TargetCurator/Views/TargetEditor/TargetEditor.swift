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
                    SubTargetsField(subTargets: $subTargets, subDesignations: $subDesignations)
                    CoordinatesField(ra: $ra, dec: $dec, subTargets: subTargets)
                    TypeField(type: $type)
                }
                VStack(alignment: .leading) {
                    ConstellationField(constellation: $constellation)
                    DescriptionField(description: $description, wikipediaURL: $wikipediaURL)
                    ImageField(image: $image, target: target)
                    SizeField(arcLength: $arcLength, arcWidth: $arcWidth)
                    MagnitudeField(magnitude: $apparentMag)
                }
            }
            .padding()
        }
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
