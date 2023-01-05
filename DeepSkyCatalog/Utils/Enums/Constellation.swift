//
//  Constellation.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/19/22.
//

import Foundation

enum Constellation: String, Filter {
    var id: Self { self }
    static let name = "Constellation"
    
    case andromeda = "andromeda"
    case cetus = "cetus"
    case sculptor = "sculptor"
    case cassiopeia = "cassiopeia"
    case triangulum = "triangulum"
    case pisces = "pisces"
    case perseus = "perseus"
    case aries = "aries"
    case camelopardalis = "camelopardalis"
    case taurus = "taurus"
    case eridanus = "eridanus"
    case auriga = "auriga"
    case orion = "orion"
    case gemini = "gemini"
    case monoceros = "monoceros"
    case canisMajor = "canisMajor"
    case puppis = "puppis"
    case cancer = "cancer"
    case leo = "leo"
    case ursaMajor = "ursaMajor"
    case canesVenatici = "canesVenatici"
    case comaBerenices = "comaBerenices"
    case virgo = "virgo"
    case draco = "draco"
    case serpens = "serpens"
    case hercules = "hercules"
    case ophiuchus = "ophiuchus"
    case sagittarius = "sagittarius"
    case scutum = "scutum"
    case lyra = "lyra"
    case aquila = "aquila"
    case vulpecula = "vulpecula"
    case cygnus = "cygnus"
    case cepheus = "cepheus"
    case pegasus = "pegasus"
    case aquarius = "aquarius"
}
