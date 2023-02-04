//
//  FetchError.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/15/22.
//

import Foundation

enum FetchError: Error {
    case unableToFetch
    case unableToDecode
    case unableToMakeURL
}
