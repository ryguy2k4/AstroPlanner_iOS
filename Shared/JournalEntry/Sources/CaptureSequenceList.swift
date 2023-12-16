//
//  CaptureSequenceList.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 11/28/23.
//

import Foundation

struct CaptureSequenceList: Codable, Hashable {
    let targetName: String
    let mode: String
    let raHours: Double
    let raMinutes: Double
    let raSeconds: Double
    let decDegrees: Double
    let decMinutes: Double
    let decSeconds: Double
    let rotation: Double
    let delay: Int
    let slewToTarget: Bool
    let autoFocusOnStart: Bool
    let centerTarget: Bool
    let rotateTarget: Bool
    let startGuiding: Bool
    let autoFocusOnFilterChange: Bool
    let autoFocusAfterSetTime: Bool
    let autoFocusSetTime: Int
    let autoFocusAfterSetExposures: Bool
    let autoFocusSetExposures: Int
    let autoFocusAfterTemperatureChange: Bool
    let autoFocusAfterTemperatureChangeAmount: Int
    let autoFocusAfterHFRChange: Bool
    let autoFocusAfterHFRChangeAmount: Int
    let coordinates: Coordinates
    let negativeDec: Bool
    let captureSequences: [CaptureSequence]


    enum CodingKeys: String, CodingKey {
        case targetName = "TargetName"
        case mode = "Mode"
        case raHours = "RAHours"
        case raMinutes = "RAMinutes"
        case raSeconds = "RASeconds"
        case decDegrees = "DecDegrees"
        case decMinutes = "DecMinutes"
        case decSeconds = "DecSeconds"
        case rotation = "Rotation"
        case delay = "Delay"
        case slewToTarget = "SlewToTarget"
        case autoFocusOnStart = "AutoFocusOnStart"
        case centerTarget = "CenterTarget"
        case rotateTarget = "RotateTarget"
        case startGuiding = "StartGuiding"
        case autoFocusOnFilterChange = "AutoFocusOnFilterChange"
        case autoFocusAfterSetTime = "AutoFocusAfterSetTime"
        case autoFocusSetTime = "AutoFocusSetTime"
        case autoFocusAfterSetExposures = "AutoFocusAfterSetExposures"
        case autoFocusSetExposures = "AutoFocusSetExposures"
        case autoFocusAfterTemperatureChange = "AutoFocusAfterTemperatureChange"
        case autoFocusAfterTemperatureChangeAmount = "AutoFocusAfterTemperatureChangeAmount"
        case autoFocusAfterHFRChange = "AutoFocusAfterHFRChange"
        case autoFocusAfterHFRChangeAmount = "AutoFocusAfterHFRChangeAmount"
        case coordinates = "Coordinates"
        case negativeDec = "NegativeDec"
        case captureSequences = "CaptureSequence"

    }
    
    struct CaptureSequence: Codable, Hashable {
        let enabled: Bool
        let exposureTime: Int
        let imageType: String
        let filterType: FilterType
        let binning: Binning
        let gain: Int
        let offset: Int
        let totalExposureCount: Int
        let progressExposureCount: Int
        let dither: Bool
        let ditherAmount: Int
        
        enum CodingKeys: String, CodingKey {
            case enabled = "Enabled"
            case exposureTime = "ExposureTime"
            case imageType = "ImageType"
            case filterType = "FilterType"
            case binning = "Binning"
            case gain = "Gain"
            case offset = "Offset"
            case totalExposureCount = "TotalExposureCount"
            case progressExposureCount = "ProgressExposureCount"
            case dither = "Dither"
            case ditherAmount = "DitherAmount"
        }
        
        struct FilterType: Codable, Hashable {
            let name: String
            let focusOffset: Int
            let position: Int
            let autoFocusExposureTime: Int
            let autoFocusFilter: Bool
            let flatWizardFilterSettings: FlatWizardFilterSettings
            let autoFocusBinning: Binning
            let autoFocusGain: Int
            let autoFocusOffset: Int

            enum CodingKeys: String, CodingKey {
                case name = "Name"
                case focusOffset = "FocusOffset"
                case position = "Position"
                case autoFocusExposureTime = "AutoFocusExposureTime"
                case autoFocusFilter = "AutoFocusFilter"
                case flatWizardFilterSettings = "FlatWizardFilterSettings"
                case autoFocusBinning = "AutoFocusBinning"
                case autoFocusGain = "AutoFocusGain"
                case autoFocusOffset = "AutoFocusOffset"
            }
            
            struct FlatWizardFilterSettings: Codable, Hashable {
                let flatWizardMode: String
                let histogramMeanTarget: Double
                let histogramTolerance: Double
                let maxFlatExposureTime: Int
                let minFlatExposureTime: Double
                let stepSize: Double
                let maxAbsoluteFlatDeviceBrightness: Int
                let minAbsoluteFlatDeviceBrightness: Int
                let flatDeviceAbsoluteStepSize: Int
                
                enum CodingKeys: String, CodingKey {
                    case flatWizardMode = "FlatWizardMode"
                    case histogramMeanTarget = "HistogramMeanTarget"
                    case histogramTolerance = "HistogramTolerance"
                    case maxFlatExposureTime = "MaxFlatExposureTime"
                    case minFlatExposureTime = "MinFlatExposureTime"
                    case stepSize = "StepSize"
                    case maxAbsoluteFlatDeviceBrightness = "MaxAbsoluteFlatDeviceBrightness"
                    case minAbsoluteFlatDeviceBrightness = "MinAbsoluteFlatDeviceBrightness"
                    case flatDeviceAbsoluteStepSize = "FlatDeviceAbsoluteStepSize"
                }
            }
        }
        
        struct Binning: Codable, Hashable {
            let x: Int
            let y: Int
            
            enum CodingKeys: String, CodingKey {
                case x = "X"
                case y = "Y"
            }
        }

    }

    
    struct Coordinates: Codable, Hashable {
        let ra: Double
        let dec: Double
        let epoch: String
        
        enum CodingKeys: String, CodingKey {
            case ra = "RA"
            case dec = "Dec"
            case epoch = "Epoch"
        }
    }
}
