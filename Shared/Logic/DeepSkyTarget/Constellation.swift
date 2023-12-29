//
//  Constellation.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/19/22.
//

import Foundation

enum Constellation: String, Filter, CaseNameCodable {
    var id: Self { self }
    
    /// The name for this Filter
    static let name = "Constellation"
    
    // Most major constellations
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
    case scorpius = "Scorpius"
    case capricornus = "Capricornus"
    case hydra = "Hydra"
    case sagitta = "Sagitta"
    case lepus = "Lepus"
    case lacerta = "Lacerta"
    case lynx = "Lynx"
    case delphinus = "Delphinus"
    case bootes = "Bootes"
    case sextans = "Sextans"
    case corvus = "Corvus"
    case fornax = "Fornax"
    case coronaAustralis = "Corona Australis"
    case columba = "Columba"
    case vela = "vela"
    case centaurus = "Centaurus"
    case ara = "Ara"
    case horologium = "Horologium"
    case circinus = "Circinus"
    case carina = "Carina"
    case pavo = "Pavo"
    case crux = "Crux"
    case triangulumAustrale = "Triangulum Astrale"
    case doradp = "Dorado"
    case tucana = "Tucana"
    case musca = "Musca"
    case apus = "Apus"
    case chamaeleon = "Chamaeleon"
    case norma = "Norma"
}
