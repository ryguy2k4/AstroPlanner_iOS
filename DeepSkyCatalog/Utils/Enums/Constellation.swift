//
//  Constellation.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/19/22.
//

import Foundation

enum Constellation: String, Filter, CaseNameCodable {
    var id: Self { self }
    static let name = "Constellation"
    
    case andromeda = "Andromeda"
    case cetus = "Cetus"
    case sculptor = "Sculptor"
    case cassiopeia = "Cassiopeia"
    case triangulum = "Triangulum"
    case pisces = "Pisces"
    case perseus = "Perseus"
    case aries = "Aries"
    case camelopardalis = "Camelopardalis"
    case taurus = "Taurus"
    case eridanus = "Eridanus"
    case auriga = "Auriga"
    case orion = "Orion"
    case gemini = "Gemini"
    case monoceros = "Monoceros"
    case canisMajor = "Canis Major"
    case puppis = "Puppis"
    case cancer = "Cancer"
    case leo = "Leo"
    case ursaMajor = "Ursa Major"
    case canesVenatici = "Canes Venatici"
    case comaBerenices = "Coma Berenices"
    case virgo = "Virgo"
    case draco = "Draco"
    case serpens = "Serpens"
    case hercules = "Hercules"
    case ophiuchus = "Ophiuchus"
    case sagittarius = "Sagittarius"
    case scutum = "Scutum"
    case lyra = "Lyra"
    case aquila = "Aquila"
    case vulpecula = "Vulpecula"
    case cygnus = "Cygnus"
    case cepheus = "Cepheus"
    case pegasus = "Pegasus"
    case aquarius = "Aquarius"
}
