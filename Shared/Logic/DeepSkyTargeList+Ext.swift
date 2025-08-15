//
//  DeepSkyTargeList+Ext.swift
//  DeepSkyCatalog 
//
//  Created by Ryan Sponzilli on 8/15/25.
//

import DeepSkyCore

extension DeepSkyTargetList {
    /**
     - Returns: Every DeepSkyTarget from allTargets except the ones saved as hiddenTargets in ReportSettings
     */
    static func whitelistedTargets(hiddenTargets: [HiddenTarget]) -> [DeepSkyTarget] {
        var whitelist = allTargets
        for item in hiddenTargets {
            whitelist.removeAll(where: {$0.id == item.id})
        }
        return whitelist
    }
}
