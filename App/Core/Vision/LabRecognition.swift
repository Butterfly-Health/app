//
//  LabRecognition.swift
//  App
//
//  Created by Saf on 12/15/25.
//

import Vision
import UIKit
import CoreImage

class LabRecognition {
    
    private init() {
        
    }
    
    static func recognizeImage(uiimg: UIImage) throws {
        guard let cgImage = uiimg.cgImage else { return }
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)


        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { request, error in
            recognizeTextHandler(request: request, error: error, image: uiimg)
        }


        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    static func recognizeTextHandler(request: VNRequest, error: Error?, image: UIImage) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        let boundingRects: [CGRect] = observations.compactMap { observation in


            // Find the top observation.
            guard let candidate = observation.topCandidates(1).first else { return .zero }
            
            // Find the bounding-box observation for the string range.
            let stringRange = candidate.string.startIndex..<candidate.string.endIndex
            let boxObservation = try? candidate.boundingBox(for: stringRange)
            
            // Get the normalized CGRect value.
            let boundingBox = boxObservation?.boundingBox ?? .zero
            
            // Convert the rectangle from normalized coordinates to image coordinates.
            return VNImageRectForNormalizedRect(boundingBox,
                                                Int(image.size.width),
                                                Int(image.size.height))
        }

        // Process the recognized strings.
        processResults(recognizedStrings)
    }
    
    static func processResults(_ recognizedStrings: [String]) {
        
        print(recognizedStrings)
    }
    /// Process an image and return the first table detected.
    @available(iOS 26.0, *)
    private func extractTable(from image: Data) async throws -> DocumentObservation.Container.Table {


        // The Vision request.
        let request = RecognizeDocumentsRequest()


        // Perform the request on the image data and return the results.
        let observations = try await request.perform(on: image)


        // Get the first observation from the array.
        guard let document = observations.first?.document else {
            throw AppError.noDocument
        }


        // Extract the first table detected.
        guard let table = document.tables.first else {
            throw AppError.noTable
        }


        return table
    }



}
