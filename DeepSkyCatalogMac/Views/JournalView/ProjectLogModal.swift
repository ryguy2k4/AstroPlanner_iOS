//
//  ProjectLogModal.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 1/18/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ProjectLogModal: View {
    @State var WBPPURL: URL? = nil
    @State var DSSURL: URL? = nil
    @State var fitsURLs: Set<URL>? = nil
    @State var rawURLs: Set<URL>? = nil
    var body: some View {
        ScrollView {
            VStack {
                FileChooser(title: "WBPP Log", allowedContentTypes: [.log], resultURL: $WBPPURL)
                FileChooser(title: "DSS File List", allowedContentTypes: [.text], resultURL: $DSSURL)
                MultipleFileChooser(title: "FITS Images", allowedContentTypes: [.init(filenameExtension: "fits")!], resultURLs: $fitsURLs)
                MultipleFileChooser(title: "RAW Images", allowedContentTypes: [.init(filenameExtension: "cr2")!], resultURLs: $rawURLs)
                HStack {
                    VStack {
                        if let logURL = WBPPURL {
                            if let log = try? WBPP_Log(processLoggerPath: logURL) {
                                Text(log.images.count.toString)
                                ForEach(log.images, id: \.self) { image in
                                    Text(image.lastPathComponent)
                                }
                            } else {
                                Text("Failed Init")
                            }
                        }
                    }
                    VStack {
                        if let fitsURLS = fitsURLs {
                            Text(fitsURLS.count.toString)
                            ForEach(Array(fitsURLS), id: \.self) { url in
                                Text(url.lastPathComponent)
                            }
                        }
                    }
                }
                HStack {
                    VStack {
                        if let logURL = DSSURL {
                            if let log = try? DSS_FileList(processLoggerPath: logURL) {
                                Text(log.images.count.toString)
                                ForEach(log.images, id: \.self) { image in
                                    Text(image)
                                }
                            } else {
                                Text("Failed Init")
                            }
                        }
                    }
                    VStack {
                        if let rawURLs = rawURLs {
                            Text(rawURLs.count.toString)
                            ForEach(Array(rawURLs), id: \.self) { url in
                                Text(url.lastPathComponent)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 800)
    }
}
