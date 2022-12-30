//
//  DeepSkyTargetList.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/7/22.
//

import Foundation

extension Array where Element == DeepSkyTarget {
    
    func sorted(by method: SortMethod, sortDescending: Bool, location: SavedLocation, date: Date, sunData: SunData) -> Self {
        if sortDescending {
            switch method {
            case .visibility:
                return self.sorted(by: {$0.getVisibilityScore(at: location, on: date, sunData: sunData) > $1.getVisibilityScore(at: location, on: date, sunData: sunData)})
            case .meridian:
                return self.sorted(by: {$0.getMeridianScore(at: location, on: date, sunData: sunData) > $1.getMeridianScore(at: location, on: date, sunData: sunData)})
            case .dec:
                return self.sorted(by: {$0.dec > $1.dec})
            case .ra:
                return self.sorted(by: {$0.ra > $1.ra})
            case .magnitude:
                return self.sorted(by: {$0.apparentMag > $1.apparentMag})
            case .size:
                return self.sorted(by: {$0.arcLength > $1.arcLength})
            }
        } else {
            switch method {
            case .visibility:
                return self.sorted(by: {$0.getVisibilityScore(at: location, on: date, sunData: sunData) < $1.getVisibilityScore(at: location, on: date, sunData: sunData)})
            case .meridian:
                return self.sorted(by: {$0.getMeridianScore(at: location, on: date, sunData: sunData) < $1.getMeridianScore(at: location, on: date, sunData: sunData)})
            case .dec:
                return self.sorted(by: {$0.dec < $1.dec})
            case .ra:
                return self.sorted(by: {$0.ra < $1.ra})
            case .magnitude:
                return self.sorted(by: {$0.apparentMag < $1.apparentMag})
            case .size:
                return self.sorted(by: {$0.arcLength < $1.arcLength})
            }
        }
    }
    
    
    mutating func sort(by method: SortMethod, sortDescending: Bool, location: SavedLocation, date: Date, sunData: SunData) {
        self = self.sorted(by: method, sortDescending: sortDescending, location: location, date: date, sunData: sunData)
    }
        
    mutating func filter(bySearchText searchText: String) {
        self = self.filter({$0.description.localizedCaseInsensitiveContains(searchText)})
    }
    mutating func filter(byCatalogSelection catalogSelection: [DSOCatalog]) {
        self = self.filter() {
            for catalog in catalogSelection {
                for item in $0.designation {
                    if item.catalog == catalog { return true }
                }
            }
            return false
        }
    }
    mutating func filter(byConstellationSelection constellationSelection: [Constellation]) {
        self = self.filter() {
            for constellation in constellationSelection {
                if $0.constellation == constellation { return true }
            }
            return false
        }
    }
    mutating func filter(byTypeSelection typeSelection: [DSOType]) {
        self = self.filter() {
            for type in typeSelection {
                for item in $0.type {
                    if item == type { return true }
                }
            }
            return false
        }
    }
    
    mutating func filter(byBrightestMag min: Double, byDimmestMag max: Double) {
        self = self.filter() {
            if max.isNaN {
                return $0.apparentMag >= min
            }
            return $0.apparentMag >= min && $0.apparentMag <= max
        }
    }
    
    mutating func filter(byMinSize min: Double, byMaxSize max: Double) {
        self = self.filter() {
            if max.isNaN {
                return $0.arcLength >= min
            }
            return $0.arcLength >= min && $0.arcLength <= max
        }
    }
    /*
     mutating func filter(byBrightestMag min: Double, byDimmestMag max: Double? = nil) {
         self = self.filter() {
             if let max = max {
                 return $0.apparentMag >= min && $0.apparentMag <= max
             }
             return $0.apparentMag >= min
         }
     }
     
     mutating func filter(byMinSize min: Double, byMaxSize max: Double? = nil) {
         self = self.filter() {
             if let max = max {
                 return $0.arcLength >= min && $0.arcLength <= max
             }
             return $0.arcLength >= min
         }
     }
     */
    
    mutating func filter(byMinVisScore min: Double, at location: SavedLocation, on date: Date, sunData: SunData) {
        self = self.filter() {
            return $0.getVisibilityScore(at: location, on: date, sunData: sunData) >= min
        }
    }
    
    mutating func filter(byMinMerScore min: Double, at location: SavedLocation, on date: Date, sunData: SunData) {
        self = self.filter() {
            return $0.getMeridianScore(at: location, on: date, sunData: sunData) >= min
        }
    }
    
}

struct DeepSkyTargetList {
    static let allTargets = [
        DeepSkyTarget(
            name: ["Andromeda Galaxy"],
            designation: [Designation(catalog: .messier, number: 31), Designation(catalog: .ngc, number: 224)],
            image: ["andromeda"],
            description: "The Andromeda Galaxy (IPA: /ænˈdrɒmɪdə/), also known as Messier 31, M31, or NGC 224 and originally the Andromeda Nebula, is a barred spiral galaxy with diameter of about 46.56 kiloparsecs (152,000 light-years)[8] approximately 2.5 million light-years (765 kiloparsecs) from Earth and the nearest large galaxy to the Milky Way. The galaxy's name stems from the area of Earth's sky in which it appears, the constellation of Andromeda, which itself is named after the princess who was the wife of Perseus in Greek mythology.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Andromeda_Galaxy")!,
            type: [.galaxy],
            constellation: .andromeda,
            ra: Double(hour: 0, minute: 42, second: 44.3),
            dec: Double(degree: 41, minute: 16, second: 9),
            arcLength: 178,
            arcWidth: 63,
            apparentMag: 3.44
        ),
        DeepSkyTarget(
            name: ["Skull Nebula"],
            designation: [Designation(catalog: .caldwell, number: 56), Designation(catalog: .ngc, number: 246)],
            image: ["power_star"],
            description: "NGC 246 (also known as the Skull Nebula[4] or Caldwell 56) is a planetary nebula in the constellation Cetus. The nebula and the stars associated with it are listed in several catalogs, as summarized by the SIMBAD database.[1] It is roughly 1,600 light-years away.[6] The nebula's central star is the 12th magnitude[6] white dwarf HIP 3678. It is not to be confused with the Rosette Nebula (NGC 2337), which is also referred to as the Skull.[7]",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_246")!,
            type: [.planetaryNebula],
            constellation: .cetus,
            ra: Double(hour: 0, minute: 47, second: 3.338),
            dec: Double(degree: -11, minute: 52, second: 18.94),
            arcLength: 5,
            arcWidth: 4,
            apparentMag: 8
            
        ),
        DeepSkyTarget(
            name: ["Sculptor Galaxy", "Silver Coin Galaxy", "Silver Dollar Galaxy"],
            designation: [Designation(catalog: .caldwell, number: 65), Designation(catalog: .ngc, number: 253)],
            image: ["power_star"],
            description: "Sculptor Galaxy (also known as the Silver Coin, Silver Dollar Galaxy, NGC 253, or Caldwell 65) is an intermediate spiral galaxy in the constellation Sculptor. The Sculptor Galaxy is a starburst galaxy, which means that it is currently undergoing a period of intense star formation.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Sculptor_Galaxy")!,
            type: [.galaxy],
            constellation: .sculptor,
            ra: Double(hour: 0, minute: 47, second: 33),
            dec: Double(degree: -25, minute: 17, second: 18),
            arcLength: 25,
            arcWidth: 7,
            apparentMag: 8
            
        ),
        DeepSkyTarget(
            name: ["Pacman Nebula"],
            designation: [Designation(catalog: .sh2, number: 184), Designation(catalog: .ngc, number: 281), Designation(catalog: .ic, number: 11)],
            image: ["power_star"],
            description: "NGC 281, IC 11 or Sh2-184 is a bright emission nebula and part of an H II region in the northern constellation of Cassiopeia and is part of the Milky Way's Perseus Spiral Arm. This 20×30 arcmin sized nebulosity is also associated with open cluster IC 1590, several Bok globules and the multiple star, B 1. It collectively forms Sh2-184,[3] spanning over a larger area of 40 arcmin.[4] A recent distance from radio parallaxes of water masers at 22 GHz made during 2014 is estimated it lies 2.82±0.20 kpc. (9200 ly.) from us.[5] Colloquially, NGC 281 is also known as the Pacman Nebula for its resemblance to the video game character.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_281")!,
            type: [.emissionNebula],
            constellation: .cassiopeia,
            ra: Double(hour: 0, minute: 52, second: 59.3),
            dec: Double(degree: 56, minute: 37, second: 19),
            arcLength: 35,
            arcWidth: 20,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["ET Cluster", "Owl Cluster", "Dragonfly Cluster", "Kachina Doll Cluster", "Phi Cassiopeiae Cluster"],
            designation: [Designation(catalog: .caldwell, number: 13), Designation(catalog: .ngc, number: 457)],
            image: ["power_star"],
            description: "NGC 457 (also designated Caldwell 13, and known as the Dragonfly Cluster, E.T. Cluster, Owl Cluster, Kachina Doll Cluster or Phi Cassiopeiae Cluster)[2] is an open star cluster in the constellation Cassiopeia.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_457")!,
            type: [.openStarCluster],
            constellation: .cassiopeia,
            ra: Double(hour: 1, minute: 19, second: 32.6),
            dec: Double(degree: 58, minute: 17, second: 27),
            arcLength: 30,
            arcWidth: 20,
            apparentMag: 6.4
            
        ),
        DeepSkyTarget(
            name: ["Triangulum Galaxy"],
            designation: [Designation(catalog: .messier, number: 33), Designation(catalog: .ngc, number: 598)],
            image: ["power_star"],
            description: "The Triangulum Galaxy is a spiral galaxy 2.73 million light-years (ly) from Earth in the constellation Triangulum. It is catalogued as Messier 33 or NGC (New General Catalogue) 598. With the D25 isophotal diameter of 18.74 kiloparsecs (61,100 light-years), the Triangulum Galaxy is the third-largest member of the Local Group of galaxies, behind the Andromeda Galaxy and the Milky Way. It is one of the most distant permanent objects that can be viewed with the naked eye.[7]",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Triangulum_Galaxy")!,
            type: [.galaxy],
            constellation: .triangulum,
            ra: Double(hour: 1, minute: 33, second: 50.02),
            dec: Double(degree: 30, minute: 39, second: 36.7),
            arcLength: 63,
            arcWidth: 39,
            apparentMag: 5.72
            
        ),
        DeepSkyTarget(
            name: ["Phantom Galaxy"],
            designation: [Designation(catalog: .messier, number: 74), Designation(catalog: .ngc, number: 628)],
            image: ["power_star"],
            description: "Messier 74 (also known as NGC 628 and Phantom Galaxy) is a large spiral galaxy in the equatorial constellation Pisces.[a] It is about 32 million light-years away from Earth.[6] The galaxy contains two clearly defined spiral arms and is therefore used as an archetypal example of a grand design spiral galaxy.[7] The galaxy's low surface brightness makes it the most difficult Messier object for amateur astronomers to observe.[8][9] Its relatively large angular (that is, apparent) size and the galaxy's face-on orientation make it an ideal object for professional astronomers who want to study spiral arm structure and spiral density waves. It is estimated that M74 hosts about 100 billion stars.[6]",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_74")!,
            type: [.galaxy],
            constellation: .pisces,
            ra: Double(hour: 1, minute: 36, second: 41.8),
            dec: Double(degree: 15, minute: 47, second: 1),
            arcLength: 10,
            arcWidth: 10,
            apparentMag: 9.4
            
        ),
        DeepSkyTarget(
            name: ["Little Dumbbell Nebula", "Barbell Nebula", "Cork Nebula"],
            designation: [Designation(catalog: .messier, number: 76), Designation(catalog: .ngc, number: 650)],
            image: ["power_star"],
            description: "The Little Dumbbell Nebula, also known as Messier 76, NGC 650/651, the Barbell Nebula, or the Cork Nebula,[1] is a planetary nebula in northern constellation Perseus. It was discovered by Pierre Méchain in 1780 and included in Charles Messier's catalog of comet-like objects as number 76. It was first recognised as a planetary nebula in 1918 by the astronomer Heber Doust Curtis.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Little_Dumbbell_Nebula")!,
            type: [.planetaryNebula],
            constellation: .perseus,
            ra: Double(hour: 1, minute: 42, second: 24),
            dec: Double(degree: 51, minute: 34, second: 31),
            arcLength: 4,
            arcWidth: 3,
            apparentMag: 10.1
            
        ),
        DeepSkyTarget(
            name: ["Nautilus Galaxy"],
            designation: [Designation(catalog: .ngc, number: 772)],
            image: ["power_star"],
            description: "NGC 772 (also known as Arp 78) is an unbarred spiral galaxy approximately 130 million light-years away in the constellation Aries.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_772")!,
            type: [.galaxy],
            constellation: .aries,
            ra: Double(hour: 1, minute: 59, second: 19.6),
            dec: Double(degree: 19, minute: 0, second: 27),
            arcLength: 7,
            arcWidth: 5,
            apparentMag: 11.1
            
        ),
        DeepSkyTarget(
            name: ["Double Cluster"],
            designation: [Designation(catalog: .caldwell, number: 14), Designation(catalog: .ngc, number: 869)],
            image: ["power_star"],
            description: "The Double Cluster (also known as Caldwell 14) consists of the open clusters NGC 869 and NGC 884 (often designated h Persei and χ (chi) Persei, respectively), which are close together in the constellation Perseus. Both visible with the naked eye, NGC 869 and NGC 884 lie at a distance of about 7,500 light years in the Perseus Arm of the Milky Way galaxy.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Double_Cluster")!,
            type: [.openStarCluster],
            constellation: .perseus,
            ra: Double(hour: 2, minute: 20, second: 0),
            dec: Double(degree: 57, minute: 8, second: 0),
            arcLength: 60,
            arcWidth: 30,
            apparentMag: 3.7
            
        ),
        DeepSkyTarget(
            name: ["Outer Limits Galaxy", "Silver Sliver Galaxy"],
            designation: [Designation(catalog: .caldwell, number: 23), Designation(catalog: .ngc, number: 891)],
            image: ["power_star"],
            description: "NGC 891 (also known as Caldwell 23, the Silver Sliver Galaxy, and the Outer Limits Galaxy) is an edge-on unbarred spiral galaxy about 30 million light-years away in the constellation Andromeda. It was discovered by William Herschel on October 6, 1784.[3] The galaxy is a member of the NGC 1023 group of galaxies in the Local Supercluster. It has an H II nucleus.[4]",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_891")!,
            type: [.galaxy],
            constellation: .andromeda,
            ra: Double(hour: 2, minute: 22, second: 33.4),
            dec: Double(degree: 42, minute: 20, second: 57),
            arcLength: 14,
            arcWidth: 3,
            apparentMag: 10.8
            
        ),
        DeepSkyTarget(
            name: ["Amatha Galaxy"],
            designation: [Designation(catalog: .ngc, number: 925)],
            image: ["power_star"],
            description: "NGC 925 Amatha Galaxy is a barred spiral galaxy located about 30[4] million light-years away in the constellation Triangulum. The morphological classification of this galaxy is SB(s)d,[3] indicating that it has a bar structure and loosely wound spiral arms with no ring.[6] The spiral arm to the south is stronger than the northern arm, with the latter appearing flocculent and less coherent. The bar is offset from the center of the galaxy and is the site of star formation all along its length. Both of these morphological traits—a dominant spiral arm and the offset bar—are typically characteristics of a Magellanic spiral galaxy.[7]",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_925")!,
            type: [.galaxy],
            constellation: .triangulum,
            ra: Double(hour: 2, minute: 27, second: 19.913),
            dec: Double(degree: 33, minute: 34, second: 43.97),
            arcLength: 11,
            arcWidth: 6,
            apparentMag: 10.7
            
        ),
        DeepSkyTarget(
            name: ["Heart Nebula", "Running Dog Nebula"],
            designation: [Designation(catalog: .sh2, number: 190), Designation(catalog: .ngc, number: 896), Designation(catalog: .ic, number: 1805)],
            image: ["power_star"],
            description: "The Heart Nebula (also known as the Running dog nebula, IC 1805, Sharpless 2-190) is an emission nebula, 7500 light years away from Earth and located in the Perseus Arm of the Galaxy in the constellation Cassiopeia. It was discovered by William Herschel on 3 November 1787.[1] It displays glowing ionized hydrogen gas and darker dust lanes.[2]",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Heart_Nebula")!,
            type: [.emissionNebula],
            constellation: .cassiopeia,
            ra: Double(hour: 2, minute: 33, second: 22),
            dec: Double(degree: 61, minute: 26, second: 36),
            arcLength: 60,
            arcWidth: 60,
            apparentMag: 18.3
        ),
        DeepSkyTarget(
            name: ["Squid Galaxy"],
            designation: [Designation(catalog: .messier, number: 77), Designation(catalog: .ngc, number: 1068)],
            image: ["power_star"],
            description: "Messier 77 or M77, also known as NGC 1068 and the Squid Galaxy, is a barred spiral galaxy about 47 million light-years away in the constellation Cetus. Messier 77 was discovered by Pierre Méchain in 1780, who originally described it as a nebula. Méchain then communicated his discovery to Charles Messier, who subsequently listed the object in his catalog.[8] Both Messier and William Herschel described this galaxy as a star cluster.[8] Today, however, the object is known to be a galaxy.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_77")!,
            type: [.galaxy],
            constellation: .cetus,
            ra: Double(hour: 2, minute: 42, second: 40.771),
            dec: Double(degree: 0, minute: 0, second: -47.84),
            arcLength: 7,
            arcWidth: 6,
            apparentMag: 8.9
            
        ),
        DeepSkyTarget(
            name: ["Soul Nebula"],
            designation: [Designation(catalog: .sh2, number: 199), Designation(catalog: .ic, number: 1848)],
            image: ["power_star"],
            description: "Westerhout 5 (Sharpless 2-199, LBN 667, Soul Nebula) is an emission nebula located in Cassiopeia. Several small open clusters are embedded in the nebula: CR 34, 632, and 634[citation needed] (in the head) and IC 1848 (in the body). The object is more commonly called by the cluster designation IC 1848.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Westerhout_5")!,
            type: [.emissionNebula],
            constellation: .cassiopeia,
            ra: Double(hour: 2, minute: 55, second: 24),
            dec: Double(degree: 60, minute: 24, second: 36),
            arcLength: 60,
            arcWidth: 30,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["The Hidden Galaxy"],
            designation: [Designation(catalog: .caldwell, number: 5), Designation(catalog: .ic, number: 342)],
            image: ["power_star"],
            description: "IC 342 (also known as Caldwell 5) is an intermediate spiral galaxy in the constellation Camelopardalis, located relatively close to the Milky Way. Despite its size and actual brightness, its location behind dusty areas near the galactic equator makes it difficult to observe, leading to the nickname The Hidden Galaxy,[4][1] though it can readily be detected even with binoculars.[5] If the galaxy were not obscured, it would be visible by naked eye.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/IC_342")!,
            type: [.galaxy],
            constellation: .camelopardalis,
            ra: Double(hour: 3, minute: 46, second: 48.5),
            dec: Double(degree: 68, minute: 5, second: 46),
            arcLength: 7,
            arcWidth: 6,
            apparentMag: 9.1
            
        ),
        DeepSkyTarget(
            name: ["Pleiades", "The Seven Sisters"],
            designation: [Designation(catalog: .messier, number: 45)],
            image: ["power_star"],
            description: "The Pleiades (/ˈpliː.ədiːz, ˈpleɪ-, ˈplaɪ-/),[7][8] also known as The Seven Sisters, Messier 45 and other names by different cultures, is an asterism and an open star cluster containing middle-aged, hot B-type stars in the north-west of the constellation Taurus. At a distance of about 444 light years, it is among the nearest star clusters to Earth. It is the nearest Messier object to Earth, and is the most obvious cluster to the naked eye in the night sky.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Pleiades")!,
            type: [.openStarCluster],
            constellation: .taurus,
            ra: Double(hour: 3, minute: 47, second: 24),
            dec: Double(degree: 24, minute: 7, second: 0),
            arcLength: 110,
            arcWidth: 110,
            apparentMag: 1.6
            
        ),
        DeepSkyTarget(
            name: ["California Nebula"],
            designation: [Designation(catalog: .sh2, number: 220), Designation(catalog: .ngc, number: 1499)],
            image: ["power_star"],
            description: "The California Nebula (NGC 1499/Sh2-220) is an emission nebula located in the constellation Perseus. Its name comes from its resemblance to the outline of the US State of California in long exposure photographs. It is almost 2.5° long on the sky and, because of its very low surface brightness, it is extremely difficult to observe visually.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/California_Nebula")!,
            type: [.emissionNebula],
            constellation: .perseus,
            ra: Double(hour: 4, minute: 3, second: 18),
            dec: Double(degree: 36, minute: 25, second: 18),
            arcLength: 145,
            arcWidth: 40,
            apparentMag: 6
            
        ),
        DeepSkyTarget(
            name: ["Witch head Nebula"],
            designation: [Designation(catalog: .ic, number: 2118)],
            image: ["power_star"],
            description: "IC 2118 (also known as Witch Head Nebula due to its shape) is an extremely faint reflection nebula believed to be an ancient supernova remnant or gas cloud illuminated by nearby supergiant star Rigel in the constellation of Orion. The nebula lies in the Eridanus Constellation,[1] about 900 light-years from Earth. The nature of the dust particles, reflecting blue light better than red, is a factor in giving the Witch Head its blue color.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/IC_2118")!,
            type: [.reflectionNebula],
            constellation: .eridanus,
            ra: Double(hour: 5, minute: 2, second: 0),
            dec: Double(degree: -7, minute: 54, second: 0),
            arcLength: 180,
            arcWidth: 60,
            apparentMag: 13
            
        ),
        DeepSkyTarget(
            name: ["Flaming Star Nebula"],
            designation: [Designation(catalog: .caldwell, number: 31), Designation(catalog: .sh2, number: 229), Designation(catalog: .ic, number: 405)],
            image: ["power_star"],
            description: "IC 405 (also known as the Flaming Star Nebula, SH 2-229, or Caldwell 31) is an emission and reflection nebula[1] in the constellation Auriga north of the celestial equator, surrounding the bluish, irregular variable star AE Aurigae. It shines at magnitude +6.0. Its celestial coordinates are RA 05h 16.2m dec +34° 28′.[2] It is located near the emission nebula IC 410, the open clusters M38 and M36, and the K-class star Iota Aurigae.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/IC_405")!,
            type: [.emissionNebula, .reflectionNebula],
            constellation: .auriga,
            ra: Double(hour: 5, minute: 16, second: 5),
            dec: Double(degree: 34, minute: 27, second: 49),
            arcLength: 30,
            arcWidth: 19,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Tadpole Emission Nebula"],
            designation: [Designation(catalog: .ngc, number: 1893)],
            image: ["power_star"],
            description: "NGC 1893 is an open cluster in the constellation Auriga. It is about 12,400 light years away. The star cluster is embedded in the HII region IC 410.[5]",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_1893")!,
            type: [.emissionNebula, .openStarCluster],
            constellation: .auriga,
            ra: Double(hour: 5, minute: 22, second: 44),
            dec: Double(degree: 33, minute: 24, second: 4),
            arcLength: 40,
            arcWidth: 30,
            apparentMag: 7.5
            
        ),
        DeepSkyTarget(
            name: ["???Open Cluster IC 1907"],
            designation: [Designation(catalog: .ic, number: 1907)],
            image: ["power_star"],
            description: "NGC 1907 is an open star cluster around 4,500 light years from Earth. It contains around 30 stars and is over 500 million years old. With a magnitude of 8.2 it is visible in the constellation Auriga.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_1907")!,
            type: [.openStarCluster],
            constellation: .auriga,
            ra: Double(hour: 5, minute: 28, second: 6),
            dec: Double(degree: 35, minute: 19, second: 30),
            arcLength: 6,
            arcWidth: 6,
            apparentMag: 8.2
            
        ),
        DeepSkyTarget(
            name: ["Starfish Cluster"],
            designation: [Designation(catalog: .messier, number: 38), Designation(catalog: .ngc, number: 1912)],
            image: ["power_star"],
            description: "Messier 38 or M38, also known as NGC 1912 or Starfish Cluster,[4] is an open cluster of stars in the constellation of Auriga. It was discovered by Giovanni Batista Hodierna before 1654 and independently found by Le Gentil in 1749. The open clusters M36 and M37, also discovered by Hodierna, are often grouped together with M38.[5] Distance is about 1.066 kpc (3,480 ly) away from Earth.[2] The open cluster NGC 1907 lies nearby on the sky, but the two are most likely just experiencing a fly-by, having originated in different parts of the galaxy.[1]",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_38")!,
            type: [.openStarCluster],
            constellation: .auriga,
            ra: Double(hour: 5, minute: 28, second: 43),
            dec: Double(degree: 35, minute: 51, second: 18),
            arcLength: 15,
            arcWidth: 15,
            apparentMag: 7.4
            
        ),
        DeepSkyTarget(
            name: ["Crab Nebula"],
            designation: [Designation(catalog: .messier, number: 1), Designation(catalog: .ngc, number: 1952)],
            image: ["power_star"],
            description: "The Crab Nebula (catalogue designations M1, NGC 1952, Taurus A) is a supernova remnant and pulsar wind nebula in the constellation of Taurus. The common name comes from William Parsons, 3rd Earl of Rosse, who observed the object in 1842 using a 36-inch (91 cm) telescope and produced a drawing that looked somewhat like a crab. The nebula was discovered by English astronomer John Bevis in 1731, and it corresponds with a bright supernova recorded by Chinese astronomers in 1054. The nebula was the first astronomical object identified that corresponds with a historical supernova explosion.[6]",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Crab_Nebula")!,
            type: [.supernovaRemnant],
            constellation: .taurus,
            ra: Double(hour: 5, minute: 34, second: 31.94),
            dec: Double(degree: 22, minute: 0, second: 52.2),
            arcLength: 6,
            arcWidth: 4,
            apparentMag: 8.4
        ),
        DeepSkyTarget(
            name: ["Running Man Nebula"],
            designation: [Designation(catalog: .sh2, number: 279)],
            image: ["power_star"],
            description: "Sh2-279 (alternatively designated S279 or Sharpless 279) is an HII region and bright nebulae that includes a reflection nebula located in the constellation Orion. It is the northernmost part of the asterism known as Orion's Sword, lying 0.6° north of the Orion Nebula. The reflection nebula embedded in Sh2-279 is popularly known as the Running Man Nebula.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Sh2-279")!,
            type: [.reflectionNebula],
            constellation: .orion,
            ra: Double(hour: 5, minute: 35, second: 16.2),
            dec: Double(degree: -4, minute: 47, second: 7),
            arcLength: 20,
            arcWidth: 15,
            apparentMag: 7
            
        ),
        DeepSkyTarget(
            name: ["Orion Nebula"],
            designation: [Designation(catalog: .messier, number: 42), Designation(catalog: .ngc, number: 1976)],
            image: ["power_star"],
            description: "The Orion Nebula (also known as Messier 42, M42, or NGC 1976) is a diffuse nebula situated in the Milky Way, being south of Orion's Belt in the constellation of Orion.[b] It is one of the brightest nebulae and is visible to the naked eye in the night sky with apparent magnitude 4.0. It is 1,344 ± 20 light-years (412.1 ± 6.1 pc) away[3][6] and is the closest region of massive star formation to Earth. The M42 nebula is estimated to be 24 light-years across (so its apparent size from Earth is approximately 1 degree). It has a mass of about 2,000 times that of the Sun. Older texts frequently refer to the Orion Nebula as the Great Nebula in Orion or the Great Orion Nebula.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Orion_Nebula")!,
            type: [.emissionNebula, .reflectionNebula],
            constellation: .orion,
            ra: Double(hour: 5, minute: 35, second: 17.3),
            dec: Double(degree: -5, minute: 23, second: 28),
            arcLength: 66,
            arcWidth: 60,
            apparentMag: 4
            
        ),
        DeepSkyTarget(
            name: ["Horsehead Nebula"],
            designation: [Designation(catalog: .barnard, number: 33), Designation(catalog: .ic, number: 434)],
            image: ["power_star"],
            description: "Horsehead Nebula (also known as Barnard 33) is a small dark nebula in the constellation Orion.[2] The nebula is located just to the south of Alnitak, the easternmost star of Orion's Belt, and is part of the much larger Orion molecular cloud complex. It appears within the southern region of the dense dust cloud known as Lynds 1630, along the edge of the much larger, active star-forming H II region called IC 434.[3] The Horsehead Nebula is approximately 422 parsecs or 1,375 light-years from Earth.[1][3] It is one of the most identifiable nebulae because of its resemblance to a horse's head.[4]",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Horsehead_Nebula")!,
            type: [.darkNebula],
            constellation: .orion,
            ra: Double(hour: 5, minute: 40, second: 59),
            dec: Double(degree: -2, minute: 27, second: 30),
            arcLength: 60,
            arcWidth: 40,
            apparentMag: 6.8
            
        ),
        DeepSkyTarget(
            name: ["Flame Nebula"],
            designation: [Designation(catalog: .sh2, number: 227), Designation(catalog: .ngc, number: 2024)],
            image: ["power_star"],
            description: "The Flame Nebula, designated as NGC 2024 and Sh2-277, is an emission nebula in the constellation Orion. It is about 900 to 1,500 light-years away.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Flame_Nebula")!,
            type: [.emissionNebula],
            constellation: .orion,
            ra: Double(hour: 5, minute: 41, second: 54),
            dec: Double(degree: -1, minute: 51, second: 0),
            arcLength: 30,
            arcWidth: 30,
            apparentMag: 10
            
        ),
        DeepSkyTarget(
            name: ["Reflection Nebula M78"],
            designation: [Designation(catalog: .messier, number: 78), Designation(catalog: .ngc, number: 2068)],
            image: ["power_star"],
            description: "Messier 78 or M78, also known as NGC 2068, is a reflection nebula in the constellation Orion. It was discovered by Pierre Méchain in 1780 and included by Charles Messier in his catalog of comet-like objects that same year.[",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_78")!,
            type: [.reflectionNebula],
            constellation: .orion,
            ra: Double(hour: 5, minute: 46, second: 46.7),
            dec: Double(degree: 0, minute: 0, second: 50),
            arcLength: 8,
            arcWidth: 6,
            apparentMag: 8.3
            
        ),
        DeepSkyTarget(
            name: ["Open Star Cluster M37"],
            designation: [Designation(catalog: .messier, number: 37), Designation(catalog: .ngc, number: 2099)],
            image: ["power_star"],
            description: "Messier 37 (also known as M37 or NGC 2099) is the brightest and richest open cluster in the constellation Auriga. It was discovered by the Italian astronomer Giovanni Battista Hodierna before 1654. M37 was missed by French astronomer Guillaume Le Gentil when he rediscovered M36 and M38 in 1749. French astronomer Charles Messier independently rediscovered M37 in September 1764 but all three of these clusters were recorded by Hodierna. It is classified as Trumpler type I,1,r or I,2,r.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_37")!,
            type: [.openStarCluster],
            constellation: .auriga,
            ra: Double(hour: 5, minute: 52, second: 18),
            dec: Double(degree: 32, minute: 33, second: 2),
            arcLength: 15,
            arcWidth: 15,
            apparentMag: 6.2
            
        ),
        DeepSkyTarget(
            name: ["Open Star Cluster NGC 2158"],
            designation: [Designation(catalog: .ngc, number: 2158)],
            image: ["power_star"],
            description: "NGC 2158 is an open cluster in the constellation of Gemini. It is, in angle, immediately southwest of open cluster Messier 35, and is believed to be about 2 billion years old.[2] The two clusters are unrelated, as the subject is around 9,000 light years further away.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_2158")!,
            type: [.openStarCluster],
            constellation: .gemini,
            ra: Double(hour: 6, minute: 7, second: 25),
            dec: Double(degree: 24, minute: 5, second: 48),
            arcLength: 5,
            arcWidth: 5,
            apparentMag: 8.6
            
        ),
        DeepSkyTarget(
            name: ["Angle Nebula"],
            designation: [Designation(catalog: .ngc, number: 2170)],
            image: ["power_star"],
            description: "NGC 2170 is a reflection nebula in the constellation Monoceros. It was discovered on October 16, 1784 by William Herschel",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_2170")!,
            type: [.reflectionNebula],
            constellation: .monoceros,
            ra: Double(hour: 6, minute: 7, second: 31.3),
            dec: Double(degree: -6, minute: 23, second: 53),
            arcLength: 20,
            arcWidth: 10,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Open Cluster M35"],
            designation: [Designation(catalog: .messier, number: 35), Designation(catalog: .ngc, number: 2168)],
            image: ["power_star"],
            description: "Messier 35 or M35, also known as NGC 2168, is a relatively close open cluster of stars in the west of Gemini, at about the declination of the sun when the latter is at June solstice.[a] It was discovered by Philippe Loys de Chéseaux around 1745 and independently discovered by John Bevis before 1750.[3] It is scattered over part of the sky almost the size of the full moon and is 2,970 light-years (912 parsecs) away.[1] The compact open cluster NGC 2158 lies directly southwest of it.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_35")!,
            type: [.openStarCluster],
            constellation: .gemini,
            ra: Double(hour: 6, minute: 8, second: 54),
            dec: Double(degree: 24, minute: 20, second: 0),
            arcLength: 25,
            arcWidth: 25,
            apparentMag: 5.3
            
        ),
        DeepSkyTarget(
            name: ["Monkey Head Nebula"],
            designation: [Designation(catalog: .ngc, number: 2174)],
            image: ["power_star"],
            description: "NGC 2174 (also known as Monkey Head Nebula) is an H II[1] emission nebula located in the constellation Orion and is associated with the open star cluster NGC 2175.[1] It is thought to be located about 6,400 light-years away from Earth. The nebula may have formed through hierarchical collapse.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_2174")!,
            type: [.emissionNebula],
            constellation: .orion,
            ra: Double(hour: 6, minute: 9, second: 42),
            dec: Double(degree: 20, minute: 30, second: 0),
            arcLength: 45,
            arcWidth: 35,
            apparentMag: 6.8
            
        ),
        DeepSkyTarget(
            name: ["Jellyfish Nebula"],
            designation: [Designation(catalog: .ic, number: 443), Designation(catalog: .sh2, number: 248)],
            image: ["power_star"],
            description: "IC 443 (also known as the Jellyfish Nebula and Sharpless 248 (Sh2-248)) is a galactic supernova remnant (SNR) in the constellation Gemini. On the plane of the sky, it is located near the star Eta Geminorum. Its distance is roughly 5,000 light years from Earth.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/IC_443")!,
            type: [.supernovaRemnant],
            constellation: .gemini,
            ra: Double(hour: 6, minute: 17, second: 13),
            dec: Double(degree: 22, minute: 31, second: 5),
            arcLength: 50,
            arcWidth: 40,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Rosette Nebula"],
            designation: [Designation(catalog: .caldwell, number: 49), Designation(catalog: .sh2, number: 275)],
            image: ["power_star"],
            description: "The Rosette Nebula (also known as Caldwell 49) is an H II region located near one end of a giant molecular cloud in the Monoceros region of the Milky Way Galaxy. The open cluster NGC 2244 (Caldwell 50) is closely associated with the nebulosity, the stars of the cluster having been formed from the nebula's matter.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Rosette_Nebula")!,
            type: [.emissionNebula],
            constellation: .monoceros,
            ra: Double(hour: 6, minute: 33, second: 45),
            dec: Double(degree: 4, minute: 59, second: 54),
            arcLength: 80,
            arcWidth: 60,
            apparentMag: 9
            
        ),
        DeepSkyTarget(
            name: ["Christmas Tree Cluster and Cone Nebula"],
            designation: [Designation(catalog: .ngc, number: 2264)],
            image: ["power_star"],
            description: "NGC 2264 is the designation number of the New General Catalogue that identifies two astronomical objects as a single object: the Cone Nebula, and the Christmas Tree Cluster. Two other objects are within this designation but not officially included, the Snowflake Cluster,[3][4] and the Fox Fur Nebula.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_2264")!,
            type: [.darkNebula, .openStarCluster, .emissionNebula, .reflectionNebula],
            constellation: .monoceros,
            ra: Double(hour: 6, minute: 41, second: 0),
            dec: Double(degree: 9, minute: 53, second: 0),
            arcLength: 20,
            arcWidth: 20,
            apparentMag: 3.9
            
        ),
        DeepSkyTarget(
            name: ["Thor's Helmet"],
            designation: [Designation(catalog: .ngc, number: 2359)],
            image: ["power_star"],
            description: "NGC 2359 (also known as Thor's Helmet) is an emission nebula[3] in the constellation Canis Major. The nebula is approximately 3,670 parsecs (11.96 thousand light years) away and 30 light-years in size. The central star is the Wolf-Rayet star WR7, an extremely hot star thought to be in a brief pre-supernova stage of evolution. It is similar in nature to the Bubble Nebula, but interactions with a nearby large molecular cloud are thought to have contributed to the more complex shape and curved bow-shock structure of Thor's Helmet.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_2359")!,
            type: [.emissionNebula],
            constellation: .canisMajor,
            ra: Double(hour: 7, minute: 18, second: 30),
            dec: Double(degree: -13, minute: 13, second: 48),
            arcLength: 16,
            arcWidth: 8,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Medusa Nebula"],
            designation: [Designation(catalog: .sh2, number: 274)],
            image: ["power_star"],
            description: "The Medusa Nebula is a planetary nebula in the constellation of Gemini. It is also known as Abell 21 and Sharpless 2-274. It was originally discovered in 1955 by University of California, Los Angeles astronomer George O. Abell, who classified it as an old planetary nebula.[4] Until the early 1970s, the nebula was thought to be a supernova remnant. With the computation of expansion velocities and the thermal character of the radio emission, Soviet astronomers in 1971 concluded that it was most likely a planetary nebula.[4] As the nebula is so large, its surface brightness is very low, with surface magnitudes of between +15.99 and +25 reported.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Medusa_Nebula")!,
            type: [.planetaryNebula],
            constellation: .gemini,
            ra: Double(hour: 7, minute: 29, second: 2.69),
            dec: Double(degree: 13, minute: 14, second: 48.4),
            arcLength: 12,
            arcWidth: 12,
            apparentMag: 15.99
            
        ),
        DeepSkyTarget(
            name: ["Eskimo Nebula", "Clown-faced Nebula", "Lion Nebula"],
            designation: [Designation(catalog: .ngc, number: 2392)],
            image: ["power_star"],
            description: "The Eskimo Nebula (NGC 2392), also known as the Clown-faced Nebula, Lion Nebula,[4] or Caldwell 39, is a bipolar[5] double-shell[6] planetary nebula (PN). It was discovered by astronomer William Herschel in 1787. The formation resembles a person's head surrounded by a parka hood. It is surrounded by gas that composed the outer layers of a Sun-like star. The visible inner filaments are ejected by a strong wind of particles from the central star. The outer disk contains unusual, light-year-long filaments.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Eskimo_Nebula")!,
            type: [.planetaryNebula],
            constellation: .gemini,
            ra: Double(hour: 7, minute: 29, second: 10.7669),
            dec: Double(degree: 20, minute: 54, second: 42.488),
            arcLength: 0.7,
            arcWidth: 0.7,
            apparentMag: 10.1
            
        ),
        DeepSkyTarget(
            name: ["Open Cluster M47"],
            designation: [Designation(catalog: .messier, number: 47), Designation(catalog: .ngc, number: 2422)],
            image: ["power_star"],
            description: "Messier 47 (M47 or NGC 2422) is an open cluster in the mildly southern constellation of Puppis. It was discovered by Giovanni Batista Hodierna before 1654 and in his then keynote work re-discovered by Charles Messier on 1771.[a] It was also independently discovered by Caroline Herschel.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_47")!,
            type: [.openStarCluster],
            constellation: .puppis,
            ra: Double(hour: 7, minute: 36, second: 36),
            dec: Double(degree: -14, minute: 30, second: 0),
            arcLength: 25,
            arcWidth: 25,
            apparentMag: 4.4
            
        ),
        DeepSkyTarget(
            name: ["Spiral Galaxy NGC 2403"],
            designation: [Designation(catalog: .caldwell, number: 7), Designation(catalog: .ngc, number: 2403)],
            image: ["power_star"],
            description: "NGC 2403 (also known as Caldwell 7) is an intermediate spiral galaxy in the constellation Camelopardalis. It is an outlying member of the M81 Group,[3] and is approximately 8 million light-years distant. It bears a similarity to M33, being about 50,000 light years in diameter and containing numerous star-forming H II regions.[4] The northern spiral arm connects it to the star forming region NGC 2404.[3] NGC 2403 can be observed using 10×50 binoculars.[3] NGC 2404 is 940 light-years in diameter, making it one of the largest known H II regions. This H II region represents striking similarity with NGC 604 in M33, both in size and location in galaxy.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_2403")!,
            type: [.galaxy],
            constellation: .camelopardalis,
            ra: Double(hour: 7, minute: 36, second: 51.4),
            dec: Double(degree: 65, minute: 36, second: 9),
            arcLength: 23,
            arcWidth: 12,
            apparentMag: 8.9
            
        ),
        DeepSkyTarget(
            name: ["Open Cluster M46 and Planetary Nebula"],
            designation: [Designation(catalog: .messier, number: 46), Designation(catalog: .ngc, number: 2437)],
            image: ["power_star"],
            description: "Messier 46 or M46, also known as NGC 2437, is an open cluster of stars in the slightly southern constellation of Puppis. It was discovered by Charles Messier in 1771. Dreyer described it as very bright, very rich, very large. It is about 5,000 light-years away. There are an estimated 500 stars in the cluster with a combined mass of 453 M☉,[3] and it is thought to be a mid-range estimate of 251.2 million years old.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_46")!,
            type: [.openStarCluster, .planetaryNebula],
            constellation: .puppis,
            ra: Double(hour: 7, minute: 41, second: 46),
            dec: Double(degree: -14, minute: 48, second: 36),
            arcLength: 20,
            arcWidth: 20,
            apparentMag: 6
            
        ),
        DeepSkyTarget(
            name: ["Beehive Cluster", "Praesepe"],
            designation: [Designation(catalog: .messier, number: 44), Designation(catalog: .ngc, number: 2632)],
            image: ["power_star"],
            description: "Praesepe (Latin for manger or crib), M44, NGC 2632, or Cr 189), is an open cluster in the constellation Cancer. One of the nearest open clusters to Earth, it contains a larger population of stars than other nearby bright open clusters holding around 1,000 stars. Under dark skies, the Beehive Cluster looks like a small nebulous object to the naked eye, and has been known since ancient times. Classical astronomer Ptolemy described it as a nebulous mass in the breast of Cancer. It was among the first objects that Galileo studied with his telescope.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Beehive_Cluster")!,
            type: [.openStarCluster],
            constellation: .cancer,
            ra: Double(hour: 8, minute: 40, second: 24),
            dec: Double(degree: 19, minute: 59, second: 0),
            arcLength: 95,
            arcWidth: 95,
            apparentMag: 3.7
            
        ),
        DeepSkyTarget(
            name: ["King Cobra Cluster","Golden Eye Cluster","Ancient Open Cluster M67"],
            designation: [Designation(catalog: .messier, number: 67), Designation(catalog: .ngc, number: 2682)],
            image: ["power_star"],
            description: "Messier 67 (also known as M67 or NGC 2682) and sometimes called the King Cobra cluster or the Golden Eye cluster[5] is an open cluster in the southern, equatorial half of Cancer. It was discovered by Johann Gottfried Koehler in 1779. Estimates of its age range between 3.2 and 5 billion years. Distance estimates are likewise varied, but typically are 800–900 parsecs (2,600–2,900 ly).[1][2][3][4] Estimates of 855, 840, and 815 pc were established via binary star modelling and infrared color-magnitude diagram fitting.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_67")!,
            type: [.openStarCluster],
            constellation: .cancer,
            ra: Double(hour: 8, minute: 51, second: 18),
            dec: Double(degree: 11, minute: 49, second: 0),
            arcLength: 30,
            arcWidth: 30,
            apparentMag: 6.1
            
        ),
        DeepSkyTarget(
            name: ["Barred Spiral Galaxy NGC 2903"],
            designation: [Designation(catalog: .ngc, number: 2903)],
            image: ["power_star"],
            description: "NGC 2903 is an isolated barred spiral galaxy in the equatorial constellation of Leo, positioned about 1.5° due south of Lambda Leonis.[10] It was discovered by German-born astronomer William Herschel, who cataloged it on November 16, 1784. He mistook it as a double nebula, as did subsequent observers, and it wasn't until the nineteenth century that the Third Earl of Rosse resolved into a spiral form.[5] J. L. E. Dreyer assigned it the identifiers 2903 and 2905 in his New General Catalogue; NGC 2905 now designates a luminous knot in the northeastern spiral arm.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_2903")!,
            type: [.galaxy],
            constellation: .leo,
            ra: Double(hour: 9, minute: 32, second: 10.111),
            dec: Double(degree: 21, minute: 30, second: 2.99),
            arcLength: 13,
            arcWidth: 7,
            apparentMag: 9
            
        ),
        DeepSkyTarget(
            name: ["Bode's Galaxy"],
            designation: [Designation(catalog: .messier, number: 81), Designation(catalog: .ngc, number: 3031)],
            image: ["power_star"],
            description: "Messier 81 (also known as NGC 3031 or Bode's Galaxy) is a grand design spiral galaxy about 12 million light-years away in the constellation Ursa Major. It has a D25 isophotal diameter of 29.44 kiloparsecs (96,000 light-years).[2][5] Because of its relative proximity to the Milky Way galaxy, large size, and active galactic nucleus (which harbors a 70 million M☉[6] supermassive black hole), Messier 81 has been studied extensively by professional astronomers. The galaxy's large size and relatively high brightness also makes it a popular target for amateur astronomers.[7] In late February 2022, astronomers reported that M81 may be the source of FRB 20200120E, a repeating fast radio burst.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_81")!,
            type: [.galaxy],
            constellation: .ursaMajor,
            ra: Double(hour: 9, minute: 55, second: 33.2),
            dec: Double(degree: 69, minute: 3, second: 55),
            arcLength: 26,
            arcWidth: 14,
            apparentMag: 6.94
            
        ),
        DeepSkyTarget(
            name: ["Cigar Galaxy"],
            designation: [Designation(catalog: .messier, number: 82), Designation(catalog: .ngc, number: 3034)],
            image: ["power_star"],
            description: "Messier 82 (also known as NGC 3034, Cigar Galaxy or M82) is a starburst galaxy approximately 12 million light-years away in the constellation Ursa Major. It is the second-largest member of the M81 Group, with the D25 isophotal diameter of 12.52 kiloparsecs (40,800 light-years).[1][5] It is about five times more luminous than the Milky Way and its central region is about one hundred times more luminous.[7] The starburst activity is thought to have been triggered by interaction with neighboring galaxy M81. As one of the closest starburst galaxies to Earth, M82 is the prototypical example of this galaxy type.[7][a] SN 2014J, a type Ia supernova, was discovered in the galaxy on 21 January 2014.[8][9][10] In 2014, in studying M82, scientists discovered the brightest pulsar yet known, designated M82 X-2.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_82")!,
            type: [.galaxy],
            constellation: .ursaMajor,
            ra: Double(hour: 9, minute: 55, second: 52.2),
            dec: Double(degree: 69, minute: 40, second: 47),
            arcLength: 11,
            arcWidth: 5,
            apparentMag: 8.41
            
        ),
        DeepSkyTarget(
            name: ["Hickson 44 Galaxy Group"],
            designation: [],
            image: ["power_star"],
            description: "Hickson 44 (HCG 44) is a group of galaxies in the constellation Leo. As Arp 316, a part of this group is also designated as group of galaxies in the Atlas of Peculiar Galaxies.",
            descriptionURL: URL(string: "https://www.wikipedia.org/")!,
            type: [.galaxyGroup],
            constellation: .leo,
            ra: Double(hour: 10, minute: 18, second: 2),
            dec: Double(degree: 21, minute: 49, second: 0),
            arcLength: 22,
            arcWidth: 15,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Little Pinwheel Galaxy"],
            designation: [Designation(catalog: .ngc, number: 3184)],
            image: ["power_star"],
            description: "NGC 3184, the Little Pinwheel Galaxy, is a spiral galaxy approximately 40 million light-years away[2] in the constellation Ursa Major. It has two HII regions named NGC 3180[3] and NGC 3181",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_3184")!,
            type: [.galaxy],
            constellation: .ursaMajor,
            ra: Double(hour: 10, minute: 18, second: 17),
            dec: Double(degree: 41, minute: 25, second: 28),
            arcLength: 7,
            arcWidth: 7,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Galaxy M95"],
            designation: [Designation(catalog: .messier, number: 95), Designation(catalog: .ngc, number: 3351)],
            image: ["power_star"],
            description: "Messier 95, also known as M95 or NGC 3351, is a barred spiral galaxy about 33 million light-years away in the zodiac constellation Leo. It was discovered by Pierre Méchain in 1781, and catalogued by compatriot Charles Messier four days later. In 2012 its most recent supernova was discovered.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_95")!,
            type: [.galaxy],
            constellation: .leo,
            ra: Double(hour: 10, minute: 43, second: 57.7),
            dec: Double(degree: 11, minute: 42, second: 14),
            arcLength: 7,
            arcWidth: 5,
            apparentMag: 9.7
            
        ),
        DeepSkyTarget(
            name: ["Galaxy M96"],
            designation: [Designation(catalog: .messier, number: 96), Designation(catalog: .ngc, number: 3368)],
            image: ["power_star"],
            description: "Messier 96 (also known as M96 or NGC 3368) is an intermediate spiral galaxy about 31 million light-years away in the constellation Leo.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_96")!,
            type: [.galaxy],
            constellation: .leo,
            ra: Double(hour: 10, minute: 46, second: 45.7),
            dec: Double(degree: 11, minute: 49, second: 12),
            arcLength: 7,
            arcWidth: 5,
            apparentMag: 9.2
            
        ),
        DeepSkyTarget(
            name: ["Galaxy M108"],
            designation: [Designation(catalog: .messier, number: 108), Designation(catalog: .ngc, number: 3556)],
            image: ["power_star"],
            description: "Messier 108 (also known as NGC 3556, nicknamed the Surfboard Galaxy[6]) is a barred spiral galaxy about 28 million light-years away from Earth[3] in the northern constellation Ursa Major. It was discovered by Pierre Méchain in 1781 or 1782.[7] From the Earth, this galaxy is seen almost edge-on.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_108")!,
            type: [.galaxy],
            constellation: .ursaMajor,
            ra: Double(hour: 11, minute: 11, second: 31),
            dec: Double(degree: 55, minute: 40, second: 27),
            arcLength: 8,
            arcWidth: 3,
            apparentMag: 10
            
        ),
        DeepSkyTarget(
            name: ["Owl Nebula"],
            designation: [Designation(catalog: .messier, number: 97), Designation(catalog: .ngc, number: 3597)],
            image: ["power_star"],
            description: "The Owl Nebula (also known as Messier 97, M97 or NGC 3587) is a starburst (planetary) nebula approximately 2,030 light years away in the northern constellation Ursa Major.[2] The estimated age of the Owl Nebula is about 8,000 years.[6] It is approximately circular in cross-section with faint internal structure. It was formed from the outflow of material from the stellar wind of the central star as it evolved along the asymptotic giant branch.[5] The nebula is arranged in three concentric shells/envelopes, with the outermost shell being about 20–30% larger than the inner shell.[7] A mildly owl-like appearance of the nebula is the result of an inner shell that is not circularly symmetric, but instead forms a barrel-like structure aligned at an angle of 45° to the line of sight.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Owl_Nebula")!,
            type: [.planetaryNebula],
            constellation: .ursaMajor,
            ra: Double(hour: 11, minute: 14, second: 47.734),
            dec: Double(degree: 55, minute: 1, second: 8.5),
            arcLength: 3,
            arcWidth: 3,
            apparentMag: 9.9
            
        ),
        DeepSkyTarget(
            name: ["Leo Triplet", "M66 Group"],
            designation: [],
            image: ["power_star"],
            description: "The Leo Triplet (also known as the M66 Group) is a small group of galaxies about 35 million light-years away[5] in the constellation Leo. This galaxy group consists of the spiral galaxies M65, M66, and NGC 3628.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Leo_Triplet")!,
            type: [.galaxyGroup],
            constellation: .leo,
            ra: Double(hour: 11, minute: 17, second: 0),
            dec: Double(degree: 13, minute: 25, second: 0),
            arcLength: 50,
            arcWidth: 40,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Hamburger Galaxy"],
            designation: [Designation(catalog: .ngc, number: 3628)],
            image: ["power_star"],
            description: "Hamburger Galaxy[3] or Sarah's Galaxy,[4][5][6][7][8] is an unbarred spiral galaxy about 35 million light-years away in the constellation Leo. It was discovered by William Herschel in 1784. It has an approximately 300,000 light-years long tidal tail. Along with M65 and M66, NGC 3628 forms the Leo Triplet, a small group of galaxies. Its most conspicuous feature is the broad and obscuring band of dust located along the outer edge of its spiral arms, effectively transecting the galaxy to the view from Earth.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_3628")!,
            type: [.galaxy],
            constellation: .leo,
            ra: Double(hour: 11, minute: 20, second: 17),
            dec: Double(degree: 13, minute: 35, second: 23),
            arcLength: 14,
            arcWidth: 3,
            apparentMag: 9.5
            
        ),
        DeepSkyTarget(
            name: ["Galaxy NGC 3718"],
            designation: [Designation(catalog: .ngc, number: 3718)],
            image: ["power_star"],
            description: "NGC 3718, also called Arp 214, is a galaxy located approximately 52 million light years from Earth in the constellation Ursa Major.[4][2][5] It is either a lenticular or spiral galaxy.[6] NGC 3718 has a warped, s-shape. This may be due to gravitational interaction between it and NGC 3729, another spiral galaxy located 150,000 light-years away.[7] NGC 3718 is a member of the Ursa Major Cluster.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_3718")!,
            type: [.galaxy],
            constellation: .ursaMajor,
            ra: Double(hour: 11, minute: 32, second: 34.94),
            dec: Double(degree: 53, minute: 4, second: 4.18),
            arcLength: 22,
            arcWidth: 15,
            apparentMag: 10.61
            
        ),
        DeepSkyTarget(
            name: ["Galaxy M109"],
            designation: [Designation(catalog: .messier, number: 109), Designation(catalog: .ngc, number: 3992)],
            image: ["power_star"],
            description: "Messier 109 (also known as NGC 3992) is a barred spiral galaxy exhibiting a weak inner ring structure around the central bar approximately 83.5 ± 24 million light-years[4] away in the northern constellation Ursa Major. M109 can be seen south-east of the star Phecda (γ UMa, Gamma Ursa Majoris).",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_109")!,
            type: [.galaxy],
            constellation: .ursaMajor,
            ra: Double(hour: 11, minute: 57, second: 36),
            dec: Double(degree: 53, minute: 22, second: 28),
            arcLength: 8,
            arcWidth: 5,
            apparentMag: 9.8
            
        ),
        DeepSkyTarget(
            name: ["Silver Needle Galaxy"],
            designation: [Designation(catalog: .ngc, number: 4244)],
            image: ["power_star"],
            description: "NGC 4244, also known as Caldwell 26, is an edge-on loose spiral galaxy in the constellation Canes Venatici, and is part of the M94 Group or Canes Venatici I Group, a galaxy group relatively close to the Local Group containing the Milky Way. In the sky, it is located near the yellow naked-eye star, Beta Canum Venaticorum, but also near the barred spiral galaxy NGC 4151 and irregular galaxy NGC 4214.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_4244")!,
            type: [.galaxy],
            constellation: .canesVenatici,
            ra: Double(hour: 12, minute: 17, second: 29.9),
            dec: Double(degree: 37, minute: 17, second: 29.9),
            arcLength: 16,
            arcWidth: 2,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Galaxy M106"],
            designation: [Designation(catalog: .messier, number: 106), Designation(catalog: .ngc, number: 4258)],
            image: ["power_star"],
            description: "Messier 106 (also known as NGC 4258) is an intermediate spiral galaxy in the constellation Canes Venatici. It was discovered by Pierre Méchain in 1781. M106 is at a distance of about 22 to 25 million light-years away from Earth. M106 contains an active nucleus classified as a Type 2 Seyfert, and the presence of a central supermassive black hole has been demonstrated from radio-wavelength observations of the rotation of a disk of molecular gas orbiting within the inner light-year around the black hole.[8] NGC 4217 is a possible companion galaxy of Messier 106.[7] A Type II supernova was observed in M106 in May 2014",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_106")!,
            type: [.galaxy],
            constellation: .canesVenatici,
            ra: Double(hour: 12, minute: 18, second: 57.5),
            dec: Double(degree: 47, minute: 18, second: 14),
            arcLength: 18,
            arcWidth: 8,
            apparentMag: 8.4
            
        ),
        DeepSkyTarget(
            name: ["Galaxy M100"],
            designation: [Designation(catalog: .messier, number: 100), Designation(catalog: .ngc, number: 4321)],
            image: ["power_star"],
            description: "Messier 100 (also known as NGC 4321) is a grand design intermediate spiral galaxy in the southern part of the mildly northern Coma Berenices.[5] It is one of the brightest and largest galaxies in the Virgo Cluster and is approximately 55 million light-years[3] from our galaxy, its diameter being 107,000 light years, and being about 60% as large. It was discovered by Pierre Méchain in 1781[a] and 29 days later seen again and entered by Charles Messier in his catalogue \"of nebulae and star clusters\".[6][7]. It was one of the first spiral galaxies to be discovered,[7] and was listed as one of fourteen spiral nebulae by Lord William Parsons of Rosse in 1850. NGC 4323 and NGC 4328 are satellite galaxies of M100; the former is connected with it by a bridge of luminous matter.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_100")!,
            type: [.galaxy],
            constellation: .comaBerenices,
            ra: Double(hour: 12, minute: 22, second: 54.9),
            dec: Double(degree: 15, minute: 49, second: 21),
            arcLength: 7,
            arcWidth: 6,
            apparentMag: 9.3
            
        ),
        DeepSkyTarget(
            name: ["Markarian's Chain"],
            designation: [],
            image: ["power_star"],
            description: "Markarian's Chain is a stretch of galaxies that forms part of the Virgo Cluster. When viewed from Earth, the galaxies lie along a smoothly curved line. Charles Messier first discovered two of the galaxies, M84 and M86, in 1781. The other galaxies seen in the chain were discovered by William Herschel[1] and are now known primarily by their catalog numbers in John Louis Emil Dreyer's New General Catalogue, published in 1888.[2] It was ultimately named after the Soviet astrophysicist, Benjamin Markarian, who discovered their common motion in the early 1960s.[3] Member galaxies include M84 (NGC 4374), M86 (NGC 4406), NGC 4477, NGC 4473, NGC 4461, NGC 4458, NGC 4438 and NGC 4435. It is located at RA 12h 27m and Dec +13° 10′.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Markarian%27s_Chain")!,
            type: [.galaxyGroup],
            constellation: .virgo,
            ra: Double(hour: 12, minute: 27, second: 0),
            dec: Double(degree: 13, minute: 10, second: 0),
            arcLength: 66,
            arcWidth: 48,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Needle Galaxy"],
            designation: [Designation(catalog: .caldwell, number: 38), Designation(catalog: .ngc, number: 4565)],
            image: ["power_star"],
            description: "NGC 4565 (also known as the Needle Galaxy or Caldwell 38) is an edge-on spiral galaxy about 30 to 50 million light-years away in the constellation Coma Berenices.[2] It lies close to the North Galactic Pole and has a visual magnitude of approximately 10. It is known as the Needle Galaxy for its narrow profile.[4] First recorded in 1785 by William Herschel, it is a prominent example of an edge-on spiral galaxy.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_4565")!,
            type: [.galaxy],
            constellation: .comaBerenices,
            ra: Double(hour: 12, minute: 36, second: 20.8),
            dec: Double(degree: 25, minute: 59, second: 16),
            arcLength: 16,
            arcWidth: 3,
            apparentMag: 10.42
            
        ),
        DeepSkyTarget(
            name: ["Sombrero Galaxy"],
            designation: [Designation(catalog: .messier, number: 104), Designation(catalog: .ngc, number: 4594)],
            image: ["power_star"],
            description: "The Sombrero Galaxy (also known as Messier Object 104, M104 or NGC 4594) is a peculiar galaxy of unclear classification[5] in the constellation borders of Virgo and Corvus, being about 9.55 megaparsecs (31.1 million light-years)[2] from the Milky Way galaxy. It is a member of the Virgo II Groups, a series of galaxies and galaxy clusters strung out from the southern edge of the Virgo Supercluster.[6] It has a diameter of approximately 15 kiloparsecs (49,000 light-years),[7] three-tenths the size of the Milky Way.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Sombrero_Galaxy")!,
            type: [.galaxy],
            constellation: .virgo,
            ra: Double(hour: 12, minute: 39, second: 59.4),
            dec: Double(degree: -11, minute: 37, second: 23),
            arcLength: 9,
            arcWidth: 4,
            apparentMag: 8
            
        ),
        DeepSkyTarget(
            name: ["Whale Galaxy"],
            designation: [Designation(catalog: .caldwell, number: 32), Designation(catalog: .ngc, number: 4631)],
            image: ["power_star"],
            description: "NGC 4631 (also known as the Whale Galaxy or Caldwell 32) is a barred spiral galaxy in the constellation Canes Venatici. This galaxy's slightly distorted wedge shape gives it the appearance of a herring or a whale, hence its nickname.[3] Because this nearby galaxy is seen edge-on from Earth, professional astronomers observe this galaxy to better understand the gas and stars located outside the plane of the galaxy.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_4631")!,
            type: [.galaxy],
            constellation: .canesVenatici,
            ra: Double(hour: 12, minute: 42, second: 8),
            dec: Double(degree: 32, minute: 32, second: 29),
            arcLength: 15,
            arcWidth: 3,
            apparentMag: 9.8
            
        ),
        DeepSkyTarget(
            name: ["Hockey Stick Galaxy", "Crowbar Galaxy"],
            designation: [Designation(catalog: .ngc, number: 4656)],
            image: ["power_star"],
            description: "NGC 4656/57 is a highly warped barred spiral galaxy located in the constellation Canes Venatici and is sometimes informally called the Hockey Stick Galaxies or the Crowbar Galaxy. Its unusual shape is thought to be due to an interaction between NGC 4656, NGC 4631, and NGC 4627.[3] The galaxy is a member of the NGC 4631 Group. A Luminous Blue Variable in \"super-outburst\" was discovered in NGC 4656/57 on March 21, 2005.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_4656_and_NGC_4657")!,
            type: [.galaxy],
            constellation: .canesVenatici,
            ra: Double(hour: 12, minute: 43, second: 57.7),
            dec: Double(degree: 32, minute: 10, second: 5),
            arcLength: 15,
            arcWidth: 3,
            apparentMag: 11
            
        ),
        DeepSkyTarget(
            name: ["Ringed Galaxy NGC 4725"],
            designation: [Designation(catalog: .ngc, number: 4725)],
            image: ["power_star"],
            description: "NGC 4725 is an intermediate barred spiral galaxy with a prominent ring structure,[9] located in the northern constellation of Coma Berenices near the north galactic pole.[10] It was discovered by German-born astronomer William Herschel on April 6, 1785.[11] The galaxy lies at a distance of approximately 40 megalight-years[4] from the Milky Way.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_4725")!,
            type: [.galaxy],
            constellation: .comaBerenices,
            ra: Double(hour: 12, minute: 50, second: 26.57),
            dec: Double(degree: 25, minute: 30, second: 2.74),
            arcLength: 11,
            arcWidth: 8,
            apparentMag: 10.1
            
        ),
        DeepSkyTarget(
            name: ["Spiral Galaxy M94"],
            designation: [Designation(catalog: .messier, number: 94), Designation(catalog: .ngc, number: 4736)],
            image: ["power_star"],
            description: "Messier 94 (also known as NGC 4736) is a spiral galaxy in the mid-northern constellation Canes Venatici. It was discovered by Pierre Méchain in 1781,[7] and catalogued by Charles Messier two days later. Although some references describe M94 as a barred spiral galaxy, the \"bar\" structure appears to be more oval-shaped.[8] The galaxy has two ring structures.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_94")!,
            type: [.galaxy],
            constellation: .canesVenatici,
            ra: Double(hour: 12, minute: 50, second: 53.1),
            dec: Double(degree: 41, minute: 7, second: 14),
            arcLength: 11,
            arcWidth: 9,
            apparentMag: 8.2
            
        ),
        DeepSkyTarget(
            name: ["Black Eye Galaxy", "Sleeping Beauty Galaxy", "Evil Eye Galaxy"],
            designation: [Designation(catalog: .messier, number: 64), Designation(catalog: .ngc, number: 4826)],
            image: ["power_star"],
            description: "The Black Eye Galaxy (also called Sleeping Beauty Galaxy or Evil Eye Galaxy and designated Messier 64, M64, or NGC 4826) is a relatively isolated[7] spiral galaxy 17 million light-years away in the mildly northern constellation of Coma Berenices. It was discovered by Edward Pigott in March 1779, and independently by Johann Elert Bode in April of the same year, as well as by Charles Messier the next year. A dark band of absorbing dust partially in front of its bright nucleus gave rise to its nicknames of the \"Black Eye\", \"Evil Eye\", or \"Sleeping Beauty\" galaxy.[11][12] M64 is well known among amateur astronomers due to its form in small telescopes and visibility across inhabited latitudes.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Black_Eye_Galaxy")!,
            type: [.galaxy],
            constellation: .comaBerenices,
            ra: Double(hour: 12, minute: 56, second: 43.7),
            dec: Double(degree: 21, minute: 40, second: 57.57),
            arcLength: 9,
            arcWidth: 5,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Sunflower Galaxy"],
            designation: [Designation(catalog: .messier, number: 63), Designation(catalog: .ngc, number: 5055)],
            image: ["power_star"],
            description: "Messier 63 or M63, also known as NGC 5055 or the seldom-used Sunflower Galaxy,[6] is a spiral galaxy in the northern constellation of Canes Venatici with approximately 400 billion stars.[7] M63 was first discovered by the French astronomer Pierre Méchain, then later verified by his colleague Charles Messier on June 14, 1779.[6] The galaxy became listed as object 63 in the Messier Catalogue. In the mid-19th century, Anglo-Irish astronomer Lord Rosse identified spiral structures within the galaxy, making this one of the first galaxies in which such structure was identified.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_63")!,
            type: [.galaxy],
            constellation: .canesVenatici,
            ra: Double(hour: 13, minute: 15, second: 49.27),
            dec: Double(degree: 42, minute: 1, second: 45.73),
            arcLength: 12,
            arcWidth: 8,
            apparentMag: 9.3
            
        ),
        DeepSkyTarget(
            name: ["Whirlpool Galaxy"],
            designation: [Designation(catalog: .messier, number: 51), Designation(catalog: .ngc, number: 5194)],
            image: ["power_star"],
            description: "The Whirlpool Galaxy, also known as Messier 51a, M51a, and NGC 5194, is an interacting grand-design spiral galaxy with a Seyfert 2 active galactic nucleus.[6][7][8] It lies in the constellation Canes Venatici, and was the first galaxy to be classified as a spiral galaxy.[9] Its distance is 31 million light-years away from Earth",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Whirlpool_Galaxy")!,
            type: [.galaxy],
            constellation: .canesVenatici,
            ra: Double(hour: 13, minute: 29, second: 52.7),
            dec: Double(degree: 47, minute: 11, second: 43),
            arcLength: 11,
            arcWidth: 8,
            apparentMag: 8.4
            
        ),
        DeepSkyTarget(
            name: ["Globular Cluster M3"],
            designation: [Designation(catalog: .messier, number: 3), Designation(catalog: .ngc, number: 5272)],
            image: ["power_star"],
            description: "Messier 3 (M3; also NGC 5272) is a globular cluster of stars in the northern constellation of Canes Venatici.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_3")!,
            type: [.globularStarCluster],
            constellation: .canesVenatici,
            ra: Double(hour: 13, minute: 42, second: 11.62),
            dec: Double(degree: 28, minute: 22, second: 38.2),
            arcLength: 18,
            arcWidth: 18,
            apparentMag: 6.39
            
        ),
        DeepSkyTarget(
            name: ["Pinwheel Galaxy"],
            designation: [Designation(catalog: .messier, number: 101), Designation(catalog: .ngc, number: 5457)],
            image: ["power_star"],
            description: "The Pinwheel Galaxy (also known as Messier 101, M101 or NGC 5457) is a face-on spiral galaxy 21 million light-years (6.4 megaparsecs)[5] away from Earth in the constellation Ursa Major. It was discovered by Pierre Méchain in 1781[a] and was communicated that year to Charles Messier, who verified its position for inclusion in the Messier Catalogue as one of its final entries.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Pinwheel_Galaxy")!,
            type: [.galaxy],
            constellation: .ursaMajor,
            ra: Double(hour: 14, minute: 3, second: 12.6),
            dec: Double(degree: 54, minute: 20, second: 57),
            arcLength: 29,
            arcWidth: 27,
            apparentMag: 7.9
            
        ),
        DeepSkyTarget(
            name: ["Splinter Galaxy"],
            designation: [Designation(catalog: .ngc, number: 5907)],
            image: ["power_star"],
            description: "NGC 5907 (also known as Knife Edge Galaxy or Splinter Galaxy) is a spiral galaxy located approximately 50 million light years from Earth.[2] It has an anomalously low metallicity and few detectable giant stars, being apparently composed almost entirely of dwarf stars.[3] It is a member of the NGC 5866 Group.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_5907")!,
            type: [.galaxy],
            constellation: .draco,
            ra: Double(hour: 15, minute: 15, second: 53.8),
            dec: Double(degree: 56, minute: 19, second: 44),
            arcLength: 12,
            arcWidth: 2,
            apparentMag: 11.1
            
        ),
        DeepSkyTarget(
            name: ["Globular Cluster M5"],
            designation: [Designation(catalog: .messier, number: 5), Designation(catalog: .ngc, number: 5904)],
            image: ["power_star"],
            description: "Messier 5 or M5 (also designated NGC 5904) is a globular cluster in the constellation Serpens. It was discovered by Gottfried Kirch in 1702.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_5")!,
            type: [.globularStarCluster],
            constellation: .serpens,
            ra: Double(hour: 15, minute: 18, second: 33.22),
            dec: Double(degree: 2, minute: 4, second: 51.7),
            arcLength: 23,
            arcWidth: 23,
            apparentMag: 5.6
            
        ),
        DeepSkyTarget(
            name: ["Great Hercules Cluster"],
            designation: [Designation(catalog: .messier, number: 13), Designation(catalog: .ngc, number: 6205)],
            image: ["power_star"],
            description: "Messier 13 or M13, also designated NGC 6205 and sometimes called the Great Globular Cluster in Hercules or the Hercules Globular Cluster, is a globular cluster of several hundred thousand stars in the constellation of Hercules.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_13")!,
            type: [.globularStarCluster],
            constellation: .hercules,
            ra: Double(hour: 16, minute: 41, second: 41.24),
            dec: Double(degree: 36, minute: 27, second: 35.5),
            arcLength: 29,
            arcWidth: 20,
            apparentMag: 5.8
            
        ),
        DeepSkyTarget(
            name: ["Globular Cluster M12"],
            designation: [Designation(catalog: .messier, number: 12), Designation(catalog: .ngc, number: 6218)],
            image: ["power_star"],
            description: "Messier 12 or M 12 (also designated NGC 6218) is a globular cluster in the constellation of Ophiuchus. It was discovered by the French astronomer Charles Messier on May 30, 1764, who described it as a \"nebula without stars\".[8] In dark conditions this cluster can be faintly seen with a pair of binoculars. Resolving the stellar components requires a telescope with an aperture of 8 in (20 cm) or greater.[9] In a 10 in (25 cm) scope, the granular core shows a diameter of 3′ (arcminutes) surrounded by a 10′ halo of stars.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_12")!,
            type: [.globularStarCluster],
            constellation: .ophiuchus,
            ra: Double(hour: 16, minute: 47, second: 14.18),
            dec: Double(degree: -1, minute: 56, second: 54.7),
            arcLength: 16,
            arcWidth: 16,
            apparentMag: 6.7
            
        ),
        DeepSkyTarget(
            name: ["Cat's Eye Nebula"],
            designation: [Designation(catalog: .caldwell, number: 6), Designation(catalog: .ngc, number: 6543)],
            image: ["power_star"],
            description: "The Cat's Eye Nebula (also known as NGC 6543 and Caldwell 6) is a planetary nebula in the northern constellation of Draco, discovered by William Herschel on February 15, 1786. It was the first planetary nebula whose spectrum was investigated by the English amateur astronomer William Huggins, demonstrating that planetary nebulae were gaseous and not stellar in nature. Structurally, the object has had high-resolution images by the Hubble Space Telescope revealing knots, jets, bubbles and complex arcs, being illuminated by the central hot planetary nebula nucleus (PNN).[3] It is a well-studied object that has been observed from radio to X-ray wavelengths.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Cat%27s_Eye_Nebula")!,
            type: [.planetaryNebula],
            constellation: .draco,
            ra: Double(hour: 17, minute: 58, second: 33.423),
            dec: Double(degree: 66, minute: 37, second: 59.52),
            arcLength: 5.8,
            arcWidth: 5.8,
            apparentMag: 9.8
            
        ),
        DeepSkyTarget(
            name: ["Trifid Nebula"],
            designation: [Designation(catalog: .messier, number: 20), Designation(catalog: .ngc, number: 6514)],
            image: ["power_star"],
            description: "The Trifid Nebula (catalogued as Messier 20 or M20 and as NGC 6514) is an H II region in the north-west of Sagittarius in a star-forming region in the Milky Way's Scutum-Centaurus Arm.[3] It was discovered by Charles Messier on June 5, 1764.[4] Its name means 'three-lobe'. The object is an unusual combination of an open cluster of stars, an emission nebula (the relatively dense, reddish-pink portion), a reflection nebula (the mainly NNE blue portion), and a dark nebula (the apparent 'gaps' in the former that cause the trifurcated appearance, also designated Barnard 85). Viewed through a small telescope, the Trifid Nebula is a bright and peculiar object, and is thus a perennial favorite of amateur astronomers.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Trifid_Nebula")!,
            type: [.emissionNebula],
            constellation: .sagittarius,
            ra: Double(hour: 18, minute: 2, second: 23),
            dec: Double(degree: -23, minute: 1, second: 48),
            arcLength: 29,
            arcWidth: 27,
            apparentMag: 6.3
            
        ),
        DeepSkyTarget(
            name: ["Lagoon Nebula"],
            designation: [Designation(catalog: .messier, number: 8), Designation(catalog: .ngc, number: 6523)],
            image: ["power_star"],
            description: "The Lagoon Nebula (catalogued as Messier 8 or M8, NGC 6523, Sharpless 25, RCW 146, and Gum 72) is a giant interstellar cloud in the constellation Sagittarius. It is classified as an emission nebula and as an H II region.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Lagoon_Nebula")!,
            type: [.emissionNebula],
            constellation: .sagittarius,
            ra: Double(hour: 18, minute: 3, second: 37),
            dec: Double(degree: -24, minute: 23, second: 12),
            arcLength: 90,
            arcWidth: 40,
            apparentMag: 4.6
            
        ),
        DeepSkyTarget(
            name: ["Eagle Nebula"],
            designation: [Designation(catalog: .messier, number: 16), Designation(catalog: .ngc, number: 6611)],
            image: ["power_star"],
            description: "The Eagle Nebula (catalogued as Messier 16 or M16, and as NGC 6611, and also known as the Star Queen Nebula) is a young open cluster of stars in the constellation Serpens, discovered by Jean-Philippe de Cheseaux in 1745–46. Both the \"Eagle\" and the \"Star Queen\" refer to visual impressions of the dark silhouette near the center of the nebula,[4][5] an area made famous as the \"Pillars of Creation\" imaged by the Hubble Space Telescope. The nebula contains several active star-forming gas and dust regions, including the aforementioned Pillars of Creation. The Eagle Nebula lies in the Sagittarius Arm of the Milky Way.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Eagle_Nebula")!,
            type: [.emissionNebula],
            constellation: .serpens,
            ra: Double(hour: 18, minute: 18, second: 48),
            dec: Double(degree: -13, minute: 49, second: 0),
            arcLength: 35,
            arcWidth: 28,
            apparentMag: 6.4
            
        ),
        DeepSkyTarget(
            name: ["Swan nebula", "Omega Nebula"],
            designation: [Designation(catalog: .messier, number: 17), Designation(catalog: .ngc, number: 6618)],
            image: ["power_star"],
            description: "The Omega Nebula, also known as the Swan Nebula, Checkmark Nebula, Lobster Nebula, and the Horseshoe Nebula[1][2] (catalogued as Messier 17 or M17 or NGC 6618) is an H II region in the constellation Sagittarius. It was discovered by Philippe Loys de Chéseaux in 1745. Charles Messier catalogued it in 1764. It is by some of the richest starfields of the Milky Way, figuring in the northern two-thirds of Sagittarius.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Omega_Nebula")!,
            type: [.emissionNebula],
            constellation: .sagittarius,
            ra: Double(hour: 18, minute: 20, second: 26),
            dec: Double(degree: -16, minute: 10, second: 36),
            arcLength: 46,
            arcWidth: 37,
            apparentMag: 6
            
        ),
        DeepSkyTarget(
            name: ["Globular Cluster M22"],
            designation: [Designation(catalog: .messier, number: 22), Designation(catalog: .ngc, number: 6656)],
            image: ["power_star"],
            description: "Messier 22 or M22, also known as NGC 6656, is an elliptical globular cluster of stars in the constellation Sagittarius, near the Galactic bulge region. It is one of the brightest globulars visible in the night sky. The brightest stars are 11th magnitude, with hundreds of stars bright enough to resolve with an 8\" telescope.[10] It is just south of the sun's position in mid-December , and northwest of Lambda Sagittarii (Kaus Borealis), the northernmost star of the \"Teapot\" asterism.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_22")!,
            type: [.globularStarCluster],
            constellation: .sagittarius,
            ra: Double(hour: 18, minute: 36, second: 23.94),
            dec: Double(degree: -23, minute: 54, second: 17.1),
            arcLength: 32,
            arcWidth: 32,
            apparentMag: 5.1
            
        ),
        DeepSkyTarget(
            name: ["Wild Duck Cluster"],
            designation: [Designation(catalog: .messier, number: 11), Designation(catalog: .ngc, number: 6705)],
            image: ["power_star"],
            description: "The Wild Duck Cluster (also known as Messier 11, or NGC 6705) is an open cluster of stars in the constellation Scutum (the Shield). It was discovered by Gottfried Kirch in 1681.[3] Charles Messier included it in his catalogue of diffuse objects in 1764. Its popular name derives from the brighter stars forming a triangle which could resemble a flying flock of ducks[3] (or, from other angles, one swimming duck). The cluster is located just to the east of the Scutum Star Cloud midpoint.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Wild_Duck_Cluster")!,
            type: [.openStarCluster],
            constellation: .scutum,
            ra: Double(hour: 18, minute: 51, second: 0.5),
            dec: Double(degree: -6, minute: 16, second: 12),
            arcLength: 11,
            arcWidth: 11,
            apparentMag: 5.8
            
        ),
        DeepSkyTarget(
            name: ["Ring Nebula"],
            designation: [Designation(catalog: .messier, number: 57), Designation(catalog: .ngc, number: 6720)],
            image: ["power_star"],
            description: "The Ring Nebula (also catalogued as Messier 57, M57 and NGC 6720) is a planetary nebula in the northern constellation of Lyra.[4][C] Such a nebula is formed when a star, during the last stages of its evolution before becoming a white dwarf, expels a vast luminous envelope of ionized gas into the surrounding interstellar space.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Ring_Nebula")!,
            type: [.planetaryNebula],
            constellation: .lyra,
            ra: Double(hour: 18, minute: 53, second: 35.079),
            dec: Double(degree: 33, minute: 1, second: 45.03),
            arcLength: 3,
            arcWidth: 3,
            apparentMag: 8.8
            
        ),
        DeepSkyTarget(
            name: ["Snowball Nebula"],
            designation: [Designation(catalog: .ngc, number: 6781)],
            image: ["power_star"],
            description: "NGC 6781 is a planetary nebula located in the equatorial constellation of Aquila, about 2.5° east-northeast of the 5th magnitude star 19 Aquilae.[3] It was discovered July 30, 1788 by the Anglo-German astronomer William Herschel.[5] The nebula lies at a distance of 1,500 ly from the Sun.[2] It has a visual magnitude of 11.4 and spans an angular size of 1.9 × 1.8 arcminutes.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_6781")!,
            type: [.planetaryNebula],
            constellation: .aquila,
            ra: Double(hour: 19, minute: 18, second: 28.085),
            dec: Double(degree: 6, minute: 32, second: 19.29),
            arcLength: 1.8,
            arcWidth: 1.8,
            apparentMag: 11.4
            
        ),
        DeepSkyTarget(
            name: ["Barnard's E Nebula"],
            designation: [Designation(catalog: .barnard, number: 142)],
            image: ["power_star"],
            description: "The \"E\" or \"Barnard's E\" Nebula (officially designated as Barnard 142 and 143) is a pair of dark nebula in the Aquila constellation. It is a well-defined dark area on a background of Milky Way consisting of countless stars of all magnitudes. Its size is about that of the full moon, or roughly 0.5 degrees, and its distance from earth is estimated at 2,000 light years.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/E_Nebula")!,
            type: [.darkNebula],
            constellation: .aquila,
            ra: Double(hour: 19, minute: 40, second: 42),
            dec: Double(degree: 10, minute: 57, second: 0),
            arcLength: 60,
            arcWidth: 40,
            apparentMag: .nan
            
        ),
        DeepSkyTarget(
            name: ["Barnard's Galaxy"],
            designation: [Designation(catalog: .caldwell, number: 57), Designation(catalog: .ic, number: 4895), Designation(catalog: .ngc, number: 6822)],
            image: ["power_star"],
            description: "NGC 6822 (also known as Barnard's Galaxy, IC 4895, or Caldwell 57) is a barred irregular galaxy approximately 1.6 million light-years away in the constellation Sagittarius. Part of the Local Group of galaxies, it was discovered by E. E. Barnard in 1884 (hence its name), with a six-inch refractor telescope. It is the closest non-satellite galaxy to the Milky Way, but lies just outside its virial radius.[5] It is similar in structure and composition to the Small Magellanic Cloud. It is about 7,000 light-years in diameter.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_6822")!,
            type: [.galaxy],
            constellation: .sagittarius,
            ra: Double(hour: 19, minute: 44, second: 56.6),
            dec: Double(degree: -14, minute: 47, second: 21),
            arcLength: 15,
            arcWidth: 14,
            apparentMag: 9.3
            
        ),
        DeepSkyTarget(
            name: ["Dumbbell Nebula", "Apple Core Nebula"],
            designation: [Designation(catalog: .messier, number: 27), Designation(catalog: .ngc, number: 6853)],
            image: ["power_star"],
            description: "The Dumbbell Nebula (also known as the Apple Core Nebula, Messier 27, and NGC 6853) is a planetary nebula (nebulosity surrounding a white dwarf) in the constellation Vulpecula, at a distance of about 1360 light-years.[1] It was the first such nebula to be discovered, by Charles Messier in 1764. At its brightness of visual magnitude 7.5 and diameter of about 8 arcminutes, it is easily visible in binoculars[6] and is a popular observing target in amateur telescopes.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Dumbbell_Nebula")!,
            type: [.planetaryNebula],
            constellation: .vulpecula,
            ra: Double(hour: 19, minute: 59, second: 36.34),
            dec: Double(degree: 22, minute: 43, second: 16.09),
            arcLength: 7,
            arcWidth: 7,
            apparentMag: 7.4
            
        ),
        DeepSkyTarget(
            name: ["Crescent Nebula"],
            designation: [Designation(catalog: .caldwell, number: 27), Designation(catalog: .ngc, number: 6888)],
            image: ["power_star"],
            description: "The Crescent Nebula (also known as NGC 6888, Caldwell 27, Sharpless 105) is an emission nebula in the constellation Cygnus, about 5000 light-years away from Earth. It was discovered by William Herschel in 1792.[2] It is formed by the fast stellar wind from the Wolf-Rayet star WR 136 (HD 192163) colliding with and energizing the slower moving wind ejected by the star when it became a red giant around 250,000[3] to 400,000[citation needed] years ago. The result of the collision is a shell and two shock waves, one moving outward and one moving inward. The inward moving shock wave heats the stellar wind to X-ray-emitting temperatures.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Crescent_Nebula")!,
            type: [.emissionNebula],
            constellation: .cygnus,
            ra: Double(hour: 20, minute: 12, second: 7),
            dec: Double(degree: 38, minute: 21, second: 18),
            arcLength: 29,
            arcWidth: 10,
            apparentMag: 7.4
            
        ),
        DeepSkyTarget(
            name: ["Cluster NGC 6939"],
            designation: [Designation(catalog: .ngc, number: 6939)],
            image: ["power_star"],
            description: "NGC 6939 is an open cluster in the constellation Cepheus. It was discovered by William Herschel in 1798. The cluster lies 2/3° northwest from the spiral galaxy NGC 6946. The cluster lies approximately 4,000 light years away and it is over a billion years old.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_6939")!,
            type: [.openStarCluster],
            constellation: .cepheus,
            ra: Double(hour: 20, minute: 31, second: 30),
            dec: Double(degree: 60, minute: 39, second: 42),
            arcLength: 8,
            arcWidth: 7,
            apparentMag: 7.8
            
        ),
        DeepSkyTarget(
            name: ["Fireworks Galaxy"],
            designation: [Designation(catalog: .ngc, number: 6946)],
            image: ["power_star"],
            description: "NGC 6946, sometimes referred to as the Fireworks Galaxy, is a face-on intermediate spiral galaxy with a small bright nucleus, whose location in the sky straddles the boundary between the northern constellations of Cepheus and Cygnus. Its distance from Earth is about 25.2 million light-years or 7.72 megaparsecs,[2] similar to the distance of M101 (NGC 5457) in the constellation Ursa Major.[5] Both were once considered to be part of the Local Group,[6] but are now known to be among the dozen bright spiral galaxies near the Milky Way but beyond the confines of the Local Group.[7] NGC 6946 lies within the Virgo Supercluster",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_6946")!,
            type: [.galaxy],
            constellation: .cygnus,
            ra: Double(hour: 20, minute: 34, second: 52.3),
            dec: Double(degree: 60, minute: 9, second: 14),
            arcLength: 11,
            arcWidth: 10,
            apparentMag: 9.6
            
        ),
        DeepSkyTarget(
            name: ["Veil Nebula", "Cygnus Loop"],
            designation: [Designation(catalog: .caldwell, number: 33), Designation(catalog: .ic, number: 1340)],
            image: ["power_star"],
            description: "The Veil Nebula is a cloud of heated and ionized gas and dust in the constellation Cygnus. It constitutes the visible portions of the Cygnus Loop,[5] a supernova remnant, many portions of which have acquired their own individual names and catalogue identifiers. The source supernova was a star 20 times more massive than the Sun which exploded between 10,000 and 20,000 years ago.[2] At the time of explosion, the supernova would have appeared brighter than Venus in the sky, and visible in daytime.[6] The remnants have since expanded to cover an area of the sky roughly 3 degrees in diameter (about 6 times the diameter, and 36 times the area, of the full Moon).",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Veil_Nebula")!,
            type: [.supernovaRemnant],
            constellation: .cygnus,
            ra: Double(hour: 20, minute: 45, second: 38),
            dec: Double(degree: 30, minute: 42, second: 30),
            arcLength: 180,
            arcWidth: 180,
            apparentMag: 7
            
        ),
        DeepSkyTarget(
            name: ["Pelican Nebula"],
            designation: [Designation(catalog: .ic, number: 5070)],
            image: ["power_star"],
            description: "The Pelican Nebula (also known as IC 5070 and IC 5067[1]) is an H II region associated with the North America Nebula in the constellation Cygnus. The gaseous contortions of this emission nebula bear a resemblance to a pelican, giving rise to its name.[1] The Pelican Nebula is located nearby first magnitude star Deneb, and is divided from its more prominent neighbour, the North America Nebula, by a foreground molecular cloud filled with dark dust.[2] Both are part of the larger H II region of Westerhout 40.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Pelican_Nebula")!,
            type: [.emissionNebula],
            constellation: .cygnus,
            ra: Double(hour: 20, minute: 50, second: 48),
            dec: Double(degree: 44, minute: 21, second: 0),
            arcLength: 80,
            arcWidth: 60,
            apparentMag: 8
            
        ),
        DeepSkyTarget(
            name: ["North American Nebula"],
            designation: [Designation(catalog: .caldwell, number: 20), Designation(catalog: .ngc, number: 7000)],
            image: ["power_star"],
            description: "The North America Nebula (NGC 7000 or Caldwell 20) is an emission nebula in the constellation Cygnus, close to Deneb (the tail of the swan and its brightest star). The shape of the nebula resembles that of the continent of North America, complete with a prominent Gulf of Mexico.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/North_America_Nebula")!,
            type: [.emissionNebula],
            constellation: .cygnus,
            ra: Double(hour: 20, minute: 59, second: 17.1),
            dec: Double(degree: 44, minute: 31, second: 44),
            arcLength: 129,
            arcWidth: 100,
            apparentMag: 4
            
        ),
        DeepSkyTarget(
            name: ["Fetus Nebula"],
            designation: [Designation(catalog: .ngc, number: 7008)],
            image: ["power_star"],
            description: "NGC 7008 (PK 93+5.2), also known as the Fetus Nebula is a planetary nebula with a diameter of approximately 1 light-year[2] located at a distance of 2800 light years[2] in northern Cygnus. It was discovered by William Herschel in 1787, in Slough, England. NGC 7008 (H I-192) is included in the Astronomical League's Herschel 400 observing program.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_7008")!,
            type: [.planetaryNebula],
            constellation: .cygnus,
            ra: Double(hour: 21, minute: 0, second: 32.503),
            dec: Double(degree: 54, minute: 32, second: 36.18),
            arcLength: 2.5,
            arcWidth: 1.5,
            apparentMag: 12
            
        ),
        DeepSkyTarget(
            name: ["Iris Nebula"],
            designation: [Designation(catalog: .caldwell, number: 4), Designation(catalog: .ngc, number: 7023)],
            image: ["power_star"],
            description: "The Iris Nebula (also known as NGC 7023 and Caldwell 4) is a bright reflection nebula in the constellation Cepheus. The designation NGC 7023 refers to the open cluster within the larger reflection nebula designated LBN 487.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Iris_Nebula")!,
            type: [.reflectionNebula],
            constellation: .cepheus,
            ra: Double(hour: 21, minute: 1, second: 35.6),
            dec: Double(degree: 68, minute: 10, second: 10),
            arcLength: 10,
            arcWidth: 10,
            apparentMag: 6.8
            
        ),
        DeepSkyTarget(
            name: ["Globular Cluster M15"],
            designation: [Designation(catalog: .messier, number: 15), Designation(catalog: .ngc, number: 7078)],
            image: ["power_star"],
            description: "Messier 15 or M15 (also designated NGC 7078) is a globular cluster in the constellation Pegasus. It was discovered by Jean-Dominique Maraldi in 1746 and included in Charles Messier's catalogue of comet-like objects in 1764.[citation needed] At an estimated 12.5±1.3 billion years old, it is one of the oldest known globular clusters.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_15")!,
            type: [.globularStarCluster],
            constellation: .pegasus,
            ra: Double(hour: 21, minute: 29, second: 58.33),
            dec: Double(degree: 12, minute: 10, second: 1.2),
            arcLength: 18,
            arcWidth: 18,
            apparentMag: 6.2
            
        ),
        DeepSkyTarget(
            name: ["Globular Cluster M2"],
            designation: [Designation(catalog: .messier, number: 2), Designation(catalog: .ngc, number: 7089)],
            image: ["power_star"],
            description: "Messier 2 or M2 (also designated NGC 7089) is a globular cluster in the constellation Aquarius, five degrees north of the star Beta Aquarii. It was discovered by Jean-Dominique Maraldi in 1746, and is one of the largest known globular clusters.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_2")!,
            type: [.globularStarCluster],
            constellation: .aquarius,
            ra: Double(hour: 21, minute: 33, second: 27.02),
            dec: Double(degree: -0, minute: 49, second: 23.7),
            arcLength: 17,
            arcWidth: 17,
            apparentMag: 6.5
            
        ),
        DeepSkyTarget(
            name: ["Elephant's Trunk Nebula"],
            designation: [Designation(catalog: .ic, number: 1396)],
            image: ["power_star"],
            description: "The Elephant's Trunk Nebula is a concentration of interstellar gas and dust within the much larger ionized gas region IC 1396 located in the constellation Cepheus about 2,400 light years away from Earth.[1] The piece of the nebula shown here is the dark, dense globule IC 1396A; it is commonly called the Elephant's Trunk nebula because of its appearance at visible light wavelengths, where there is a dark patch with a bright, sinuous rim.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Elephant%27s_Trunk_Nebula")!,
            type: [.emissionNebula],
            constellation: .cepheus,
            ra: Double(hour: 21, minute: 38, second: 58.75),
            dec: Double(degree: 57, minute: 29, second: 39.9),
            arcLength: 90,
            arcWidth: 90,
            apparentMag: 3.5
            
        ),
        DeepSkyTarget(
            name: ["Cocoon Nebula"],
            designation: [Designation(catalog: .caldwell, number: 19), Designation(catalog: .ic, number: 5146), Designation(catalog: .sh2, number: 125)],
            image: ["power_star"],
            description: "IC 5146 (also Caldwell 19, Sh 2-125, Barnard 168, and the Cocoon Nebula) is a reflection[2]/emission[3] nebula and Caldwell object in the constellation Cygnus. The NGC description refers to IC 5146 as a cluster of 9.5 mag stars involved in a bright and dark nebula. The cluster is also known as Collinder 470.[4] It shines at magnitude +10.0[5]/+9.3[3]/+7.2.[6] Its celestial coordinates are RA 21h 53.5m , dec +47° 16′. It is located near the naked-eye star Pi Cygni, the open cluster NGC 7209 in Lacerta, and the bright open cluster M39.[2][5] The cluster is about 4,000 ly away, and the central star that lights it formed about 100,000 years ago;[7] the nebula is about 12 arcmins across, which is equivalent to a span of 15 light years.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/IC_5146")!,
            type: [.emissionNebula, .reflectionNebula],
            constellation: .cygnus,
            ra: Double(hour: 21, minute: 53, second: 28.7),
            dec: Double(degree: 47, minute: 16, second: 1),
            arcLength: 12,
            arcWidth: 12,
            apparentMag: 7.2
            
        ),
        DeepSkyTarget(
            name: ["Wolf's Cave and Cepheus Flare"],
            designation: [Designation(catalog: .barnard, number: 175)],
            image: ["power_star"],
            description: "",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Barnard_175")!,
            type: [.reflectionNebula, .darkNebula],
            constellation: .cepheus,
            ra: Double(hour: 22, minute: 13, second: 36),
            dec: Double(degree: -20, minute: 48, second: 0),
            arcLength: 12,
            arcWidth: 6,
            apparentMag: 8.8
            
        ),
        DeepSkyTarget(
            name: ["Helix Nebula"],
            designation: [Designation(catalog: .caldwell, number: 63), Designation(catalog: .ngc, number: 7293)],
            image: ["power_star"],
            description: "The Helix Nebula (also known as NGC 7293 or Caldwell 63) is a planetary nebula (PN) located in the constellation Aquarius. Discovered by Karl Ludwig Harding, probably before 1824, this object is one of the closest of all the bright planetary nebulae to Earth[3] The distance, measured by the Gaia mission, is 655±13 light-years.[4] It is similar in appearance to the Cat's Eye Nebula and the Ring Nebula, whose size, age, and physical characteristics are similar to the Dumbbell Nebula, varying only in its relative proximity and the appearance from the equatorial viewing angle.[5] The Helix Nebula has sometimes been referred to as the \"Eye of God\" in pop culture,[6] as well as the \"Eye of Sauron\".",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Helix_Nebula")!,
            type: [.planetaryNebula],
            constellation: .aquarius,
            ra: Double(hour: 22, minute: 29, second: 38.55),
            dec: Double(degree: -20, minute: 50, second: 13.6),
            arcLength: 18,
            arcWidth: 18,
            apparentMag: 7.6
            
        ),
        DeepSkyTarget(
            name: ["Stephan's Quintet"],
            designation: [],
            image: ["power_star"],
            description: "Stephan's Quintet is a visual grouping of five galaxies of which four form the first compact galaxy group ever discovered.[2] The group, visible in the constellation Pegasus, was discovered by Édouard Stephan in 1877 at the Marseille Observatory.[3] The group is the most studied of all the compact galaxy groups.[2] The brightest member of the visual grouping (and the only non-member of the true group) is NGC 7320, which has extensive H II regions, identified as red blobs, where active star formation is occurring.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Stephan%27s_Quintet")!,
            type: [.galaxyGroup],
            constellation: .pegasus,
            ra: Double(hour: 22, minute: 35, second: 57.5),
            dec: Double(degree: 33, minute: 57, second: 36),
            arcLength: 4,
            arcWidth: 3,
            apparentMag: 12
            
        ),
        DeepSkyTarget(
            name: ["Deer Lick Galaxy Group"],
            designation: [Designation(catalog: .ngc, number: 7331)],
            image: ["power_star"],
            description: "NGC 7331 Group is a visual grouping of galaxies in the constellation Pegasus. Spiral galaxy NGC 7331 is a foreground galaxy in the same field as the collection, which is also called the Deer Lick Group.[1] It contains four other members, affectionately referred to as the \"fleas\": the lenticular or unbarred spirals NGC 7335 and NGC 7336, the barred spiral galaxy NGC 7337 and the elliptical galaxy NGC 7340. These galaxies lie at distances of approximately 332, 365, 348 and 294 million light years, respectively.[2] Although adjacent on the sky, this collection is not a galaxy group, as NGC 7331 itself is not gravitationally associated with the far more distant \"fleas\"; indeed, even they are separated by far more than the normal distances (~2 Mly) of a galaxy group.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_7331_Group")!,
            type: [.galaxyGroup],
            constellation: .pegasus,
            ra: Double(hour: 22, minute: 37, second: 0),
            dec: Double(degree: 34, minute: 25, second: 0),
            arcLength: 10,
            arcWidth: 10,
            apparentMag: 9.48
            
        ),
        DeepSkyTarget(
            name: ["The Wizard Nebula"],
            designation: [Designation(catalog: .ngc, number: 7380)],
            image: ["power_star"],
            description: "NGC 7380 is a young[4] open cluster of stars in the northern circumpolar constellation of Cepheus, discovered by Caroline Herschel in 1787. The surrounding emission nebulosity is known colloquially as the Wizard Nebula, which spans an angle of 25′. German-born astronomer William Herschel included his sister's discovery in his catalog, and labelled it H VIII.77. The nebula is known as S 142 in the 1959 Sharpless catalog (Sh2-142).[2] It is extremely difficult to observe visually, usually requiring very dark skies and an O-III filter. The NGC 7380 complex is located at a distance of approximately 8.5 kilolight-years from the Sun, in the Perseus Arm of the Milky Way",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_7380")!,
            type: [.emissionNebula, .openStarCluster],
            constellation: .cepheus,
            ra: Double(hour: 22, minute: 47, second: 21),
            dec: Double(degree: 58, minute: 7, second: 54),
            arcLength: 20,
            arcWidth: 20,
            apparentMag: 7.2
            
        ),
        DeepSkyTarget(
            name: ["Cave Nebula"],
            designation: [Designation(catalog: .caldwell, number: 9), Designation(catalog: .sh2, number: 155)],
            image: ["power_star"],
            description: "Sh2-155 (also designated Caldwell 9, Sharpless 155 or S155) is a diffuse nebula in the constellation Cepheus, within a larger nebula complex containing emission, reflection, and dark nebulosity. It is widely known as the Cave Nebula, though that name was applied earlier to Ced 201, a different nebula in Cepheus. Sh2-155 is an ionized H II region with ongoing star formation activity,[1] at an estimated distance of 725 parsecs (2400 light-years) from Earth.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Sh2-155")!,
            type: [.emissionNebula, .reflectionNebula, .darkNebula],
            constellation: .cepheus,
            ra: Double(hour: 22, minute: 57, second: 17.14),
            dec: Double(degree: 62, minute: 28, second: 33.4),
            arcLength: 50,
            arcWidth: 30,
            apparentMag: 7.7
            
        ),
        DeepSkyTarget(
            name: ["Bubble Nebula"],
            designation: [Designation(catalog: .caldwell, number: 11), Designation(catalog: .sh2, number: 162), Designation(catalog: .ngc, number: 7635)],
            image: ["power_star"],
            description: "NGC 7635, also known as the Bubble Nebula, Sharpless 162, or Caldwell 11, is an H II region[1] emission nebula in the constellation Cassiopeia. It lies close to the direction of the open cluster Messier 52. The \"bubble\" is created by the stellar wind from a massive hot, 8.7[1] magnitude young central star, SAO 20575 (BD+60°2522).[7] The nebula is near a giant molecular cloud which contains the expansion of the bubble nebula while itself being excited by the hot central star, causing it to glow.[7] It was discovered in 1787 by William Herschel.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_7635")!,
            type: [.emissionNebula],
            constellation: .cassiopeia,
            ra: Double(hour: 23, minute: 20, second: 48.3),
            dec: Double(degree: 61, minute: 12, second: 6),
            arcLength: 15,
            arcWidth: 8,
            apparentMag: 10
            
        ),
        DeepSkyTarget(
            name: ["M52 Cluster"],
            designation: [Designation(catalog: .messier, number: 52), Designation(catalog: .ngc, number: 7654)],
            image: ["power_star"],
            description: "Messier 52 or M52, also known as NGC 7654, is an open cluster of stars in the highly northern constellation of Cassiopeia. It was discovered by Charles Messier on 1774.[3][a] It can be seen from Earth under a good night sky with binoculars. The brightness of the cluster is influenced by extinction, which is stronger in the southern half.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/Messier_52")!,
            type: [.openStarCluster],
            constellation: .cassiopeia,
            ra: Double(hour: 23, minute: 24, second: 48),
            dec: Double(degree: 61, minute: 35, second: 36),
            arcLength: 16,
            arcWidth: 16,
            apparentMag: 7.3
            
        ),
        DeepSkyTarget(
            name: ["Blue Snowball Nebula"],
            designation: [Designation(catalog: .caldwell, number: 22), Designation(catalog: .ngc, number: 7662)],
            image: ["power_star"],
            description: "NGC 7662 (also known as the Blue Snowball Nebula, Snowball Nebula, and Caldwell 22) is a planetary nebula located in the constellation Andromeda.",
            descriptionURL: URL(string: "https://en.wikipedia.org/wiki/NGC_7662")!,
            type: [.planetaryNebula],
            constellation: .andromeda,
            ra: Double(hour: 23, minute: 25, second: 54),
            dec: Double(degree: 42, minute: 32, second: 6),
            arcLength: 0.6,
            arcWidth: 0.6,
            apparentMag: 8.6
            
        ),
//        DeepSkyTarget(
//            name: ["Sample"],
//            designation: [],
//            image: ["power_star"],
//            description: "",
//            descriptionURL: URL(string: "https://www.wikipedia.org/")!,
//            type: [.galaxy],
//            constellation: .orion,
//            ra: Double(hour: 0, minute: 0, second: 0),
//            dec: Double(degree: 0, minute: 0, second: 0),
//            arcLength: nil,
//            arcWidth: nil,
//            apparentMag: .nan
//
//        ),
        
    ]
}
