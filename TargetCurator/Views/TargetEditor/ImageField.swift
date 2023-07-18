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
                            .frame(width: 300)
                        TextField("ID:", text: $id)
                            .frame(width: 250)
                        Button("Extract Image Size") {
                            let imageData = try! Data(contentsOf: AssetExtractor.createLocalUrl(forImageNamed: unwrappedImage.wrappedValue.source.fileName!)!)
                            let metadata = ImageMetadata(data: imageData)
                            image!.width = Double(metadata!.width!)
                            image!.height = Double(metadata!.height!)
                            
                        }
                        TextField("Width", value: unwrappedImage.width, format: .number)
                            .frame(width: 60)
                        TextField("Height", value: unwrappedImage.height, format: .number)
                            .frame(width: 60)
                        Spacer()
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
                        image = DeepSkyTarget.TargetImage(source: .apod(id: "APOD", copyrighted: false), credit: "CREDIT", width: 0, height: 0)
                    }
                }
                HStack(spacing: 20) {
                    if let filename = image?.source.fileName, image?.astrometry == nil {
                        Button("Submit to Astrometry.net") {
                            apiService.uploadImage(NSImage(imageLiteralResourceName: filename).tiffRepresentation!, ra: target.ra, dec: target.dec)
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
                if apiService.status == .processing {
                    ProgressView {
                        if let subUrl = apiService.currentSubUrl() {
                            Link(destination: subUrl) {
                                Label("Processing", systemImage: "arrow.up.forward.square")
                            }
                        } else {
                            Text("Processing")
                        }
                    }
                    .frame(maxHeight: 10)
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

struct ImageMetadata {

    var imageProperties : [CFString: Any]

    init?(data: Data) {
        let options = [kCGImageSourceShouldCache: kCFBooleanFalse]
        if let imageSource = CGImageSourceCreateWithData(data as CFData, options as CFDictionary),
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] {
            self.imageProperties = imageProperties
        } else {
            return nil
        }
    }

    var dpi : Int? { imageProperties[kCGImagePropertyDPIWidth] as? Int }
    var width : Int? { imageProperties[kCGImagePropertyPixelWidth] as? Int }
    var height : Int? { imageProperties[kCGImagePropertyPixelHeight] as? Int }

}

//It basically just gets image from assets, saves its data to disk and return file URL.
class AssetExtractor {

    static func createLocalUrl(forImageNamed name: String) -> URL? {

        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(name).png")

        guard fileManager.fileExists(atPath: url.path) else {
            guard
                let image = NSImage(named: name),
                let data = image.tiffRepresentation
            else { return nil }

            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
            return url
        }

        return url
    }

}
