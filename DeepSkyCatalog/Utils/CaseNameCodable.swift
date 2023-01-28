//
//  CaseNameCodable.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 1/16/23.
//  Copied from StackOverflow

import Foundation

protocol CaseNameCodable: Codable, RawRepresentable, CaseIterable {}

extension CaseNameCodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let raw = Self.allCases.first(where: { $0.caseName == value })?.rawValue else { throw CaseNameCodableError(value) }
        self.init(rawValue: raw)!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(caseName)
    }

    private var caseName: String {
        return "\(self)"
    }
}

struct CaseNameCodableError: Error {
    private let caseName: String

    init(_ value: String) {
        caseName = value
    }

    var localizedDescription: String {
        #"Unable to create an enum case named "\#(caseName)""#
    }
}
