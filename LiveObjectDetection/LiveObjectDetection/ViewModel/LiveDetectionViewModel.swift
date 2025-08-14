//
//  LiveDetectionViewModel.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 14/8/25.
//

import SwiftUI
import Vision

class LiveDetectionViewModel: ObservableObject {
    let mlmodel = try? YOLOv3Tiny(configuration: MLModelConfiguration())
    @Published var detectedObjects: [DetectionModel] = []
    
    func requestDetection(_ pixelBuffers: CVPixelBuffer) {
        guard let model = mlmodel?.model,
              let vnModel = try? VNCoreMLModel(for: model) else {
            return
        }
        let request = VNCoreMLRequest(model: vnModel, completionHandler: detectionResultHandler)
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffers)
        
        do {
            try requestHandler.perform([request])
        }catch {
            debugPrint("Error happend \(error)")
        }
        
    }
    
    private func detectionResultHandler(_ request: VNRequest, error: Error?) {
        guard error == nil else { return }
        let results = request.results as! [VNRecognizedObjectObservation]
        
        DispatchQueue.main.async {[weak self] in
            self?.detectedObjects = results.map { result in
                DetectionModel(
                    id: UUID().uuidString,
                    objName: result.labels.first?.identifier ?? "",
                    confidenceRate: result.confidence,
                    area: result.boundingBox
                )
            }
            
        }
        
    }
    
}
