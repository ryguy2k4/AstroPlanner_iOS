//
//  Constellation.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/19/22.
//

import Foundation

enum Constellation: String, Filter, Codable {
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let constellation = try? container.decode(String.self)
        switch constellation {
        case "andromeda":
            self = .andromeda
        case "cetus":
            self = .cetus
        case "sculptor":
            self = .sculptor
        case "cassiopeia":
            self = .cassiopeia
        case "triangulum":
            self = .triangulum
        case "pisces":
            self = .pisces
        case "perseus":
            self = .perseus
        case "aries":
            self = .aries
        case "camelopardalis":
            self = .camelopardalis
        case "taurus":
            self = .taurus
        case "eridanus":
            self = .eridanus
        case "auriga":
            self = .auriga
        case "orion":
            self = .orion
        case "gemini":
            self = .gemini
        case "monoceros":
            self = .monoceros
        case "canisMajor":
            self = .canisMajor
        case "puppis":
            self = .puppis
        case "cancer":
            self = .cancer
        case "leo":
            self = .leo
        case "ursaMajor":
            self = .ursaMajor
        case "canesVenatici":
            self = .canesVenatici
        case "comaBerenices":
            self = .comaBerenices
        case "virgo":
            self = .virgo
        case "draco":
            self = .draco
        case "serpens":
            self = .serpens
        case "hercules":
            self = .hercules
        case "ophiuchus":
            self = .ophiuchus
        case "sagittarius":
            self = .sagittarius
        case "scutum":
            self = .scutum
        case "lyra":
            self = .lyra
        case "aquila":
            self = .aquila
        case "vulpecula":
            self = .vulpecula
        case "cygnus":
            self = .cygnus
        case "cepheus":
            self = .cepheus
        case "pegasus":
            self = .pegasus
        case "aquarius":
            self = .aquarius
        default: self = .aquarius
        }
    }
}
