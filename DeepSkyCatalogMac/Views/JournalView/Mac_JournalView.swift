//
//  Mac_JournalView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 10/3/23.
//

import SwiftUI

struct Mac_JournalView: View {
    var body: some View {
        Text("Journal View")
    }
}

/*
 Houses a list of journal entries
 Journal entries are file folders
 Plus button in the toolbar
 Each entry navigates to a JournalEntryView
 */

/*
 JournalEntry Object
 
 Group by date AND project
 
 instance variables:
 - date and times
 - location
 - target
 - weather data
    - sun
    - moon
    - temp
    - dew
    - wind
 - notes
 - gear used
 - imaging plan
 */
