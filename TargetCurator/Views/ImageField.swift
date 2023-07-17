//
//  ImageField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 7/16/23.
//

import SwiftUI

struct ImageField: View {
    let target: DeepSkyTarget
    @StateObject var apiService = APIService()
    @Binding var image: DeepSkyTarget.TargetImage?
    @State var id: String
    @State var isCopyrightInfo: Bool
    
    @State var copyrighted: Bool
    
    init(image: Binding<DeepSkyTarget.TargetImage?>, target: DeepSkyTarget) {
        self._image = image
        self.target = target
        self._id = {
            switch image.wrappedValue?.source {
            case .local(fileName: let filename):
                return State(initialValue: filename)
            case .apod(id: let id, copyrighted: _):
                return State(initialValue: id)
            case nil:
                return State(initialValue: "")
            }
        }()
        self._isCopyrightInfo = State(initialValue: image.wrappedValue?.credit != nil)
        self._copyrighted = {
            switch image.wrappedValue?.source {
            case .local(fileName: _):
                return State(initialValue: false)
            case .apod(id: _, copyrighted: let copyrighted):
                return State(initialValue: copyrighted)
            case nil:
                return State(initialValue: false)
            }
        }()
    }
    var body: some View {
        Section {
            VStack {
                // Pick type of image and image ID
                if let unwrappedImage = Binding($image) {
                    HStack {
                        Button("No Image") {
                            image = nil
                        }
                        Picker("", selection: unwrappedImage.source) {
                            Text("APOD").tag(DeepSkyTarget.TargetImage.ImageSource.apod(id: id, copyrighted: copyrighted))
                            Text("Local").tag(DeepSkyTarget.TargetImage.ImageSource.local(fileName: id))
                        }
                        TextField("ID:", text: $id)
                            .frame(width: 250)
                            .padding(.trailing)
                    }
                    HStack {
                        Toggle("Copyrighted:", isOn: $copyrighted)
                        TextField("Credit:", text: unwrappedImage.credit)
                            .frame(width: 500)
                        
                        // Button to retrieve APOD Info
                        if case .apod(id: id, copyrighted: copyrighted) = image?.source {
                            Button("Get APOD Info") {
                                Task {
                                    let image = try? await NetworkManager.shared.getImageData(for: id)
                                    
                                    if let image = image {
                                        self.image!.credit = image.copyright ?? "CREDIT"
                                        isCopyrightInfo = image.copyright != nil
                                        
                                        let fileURL = URL(fileURLWithPath: "/Users/ryansponzilli/Documents/DeepSkyCatalog Python Scripts/image script/apodurls.txt")
                                        let text = "\(id);\(image.url)\n"
                                        
                                        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                                            defer {
                                                fileHandle.closeFile()
                                            }
                                            fileHandle.seekToEndOfFile()
                                            fileHandle.write(text.data(using: .utf8)!)
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                } else {
                    Button("Add Image") {
                        image = DeepSkyTarget.TargetImage(source: .apod(id: "APOD", copyrighted: false), credit: "CREDIT")
                    }
                }
                HStack(spacing: 20) {
                    if let filename = image?.source.fileName, image?.astrometry == nil {
                        Button("Submit to Astrometry.net") {
                            apiService.uploadImage(NSImage(imageLiteralResourceName: filename).tiffRepresentation!)
                        }
                        if apiService.status == .processing {
                            ProgressView(apiService.status.rawValue)
                                .frame(height: 10)

                            if let subUrl = apiService.currentSubUrl() {
                                Link(destination: subUrl) {
                                    Label("Detailed Progress", systemImage: "arrow.up.forward.square")
                                }
                            }
                        }
                        if let info = apiService.solvedJobInfo {
                            Text("Image Solved Successfully")
                                .onAppear {
                                    image?.astrometry = info.calibration
                                }
                        }
                        Spacer()
                    }
                    if let astrometry = image?.astrometry {
                        HStack {
                            Text("Astrometry: ")
                                .fontWeight(.bold)
                            Text("RA: \(astrometry.ra)")
                            Text("DEC: \(astrometry.dec)")
                            Text("Radius: \(astrometry.radius)")
                            Text("Pixel Scale: \(astrometry.pixscale)")
                            Text("Orientation: \(astrometry.orientation)")
                            Spacer()
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text("Image")
                if let url = image?.source.url {
                    Link(destination: url) {
                        Image(systemName: "arrow.up.forward.square")
                    }
                }
            }
            .font(.title3)
            .fontWeight(.bold)
            .padding(.top)
        }
    }
}
