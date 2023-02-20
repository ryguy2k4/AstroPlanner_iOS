//
//  JournalView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/28/22.
//

import SwiftUI


/*
 Houses a list of journal entries
 Journal entries are fetchrequested
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


struct JournalView: View {
    var body: some View {
        NavigationStack {
            Text("Under Construction")
        }
        .toolbar {
            ToolbarLogo()
        }
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
    }
}
