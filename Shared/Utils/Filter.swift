//
//  Filter.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 3/16/23.
//

import Foundation

protocol Filter: RawRepresentable<String>, Identifiable, Hashable, CaseIterable where AllCases == Array<Self> {
    static var name: String { get }
}
