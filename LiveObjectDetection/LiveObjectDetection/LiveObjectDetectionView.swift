//
//  LiveObjectDetectionView.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 11/8/25.
//

import SwiftUI
import Vision

struct LiveObjectDetectionView: View {
    private let camera = CustomCameraUIView()
    let mlmodel = try? YOLOv3Tiny(configuration: MLModelConfiguration())
    @State private var detectedObjects: [DetectionModel] = []
    
    var body: some View {
        ZStack {
            CustomCameraPreview(cameraView: camera, capturedPixels: capturedPixelsHandler)
                .onAppear {
                    camera.startSession()
                }
                .onDisappear {
                    camera.stopSession()
                }
                .overlay(overlayingView)
            
        }
        
    }
    
    var overlayingView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(detectedObjects, id: \.id) { object in
                    let vnRect = VNImageRectForNormalizedRect(
                        object.area,
                        Int(geometry.size.width),
                        Int(geometry.size.height)
                    )
                    let cgrect = CGRect(
                        x: vnRect.origin.x,
                        y: geometry.size.height - vnRect.height - vnRect.origin.y,
                        width: vnRect.width,
                        height: vnRect.height
                    )
                    
                    Path { path in
                        path.addRect(cgrect)
                    }
                    .stroke(.red, lineWidth: 3.0)
                    
                    Text(object.objName)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .frame(height: 16)
                        .background(Color.black.opacity(0.6))
                        .position(
                            x: cgrect.midX,
                            y: cgrect.minY - 16
                        )
                }
            }
        }
    }

    private func capturedPixelsHandler(pixelBuffers: CVPixelBuffer) {
        debugPrint("Captured Pixels at \(Date())")
        
        guard let model = mlmodel?.model,
              let vnModel = try? VNCoreMLModel(for: model) else {
            return
        }
        let request = VNCoreMLRequest(model: vnModel) { (response, error) in
            guard error == nil else { return }
            let results = response.results as! [VNRecognizedObjectObservation]
            
            self.detectedObjects = results.map { result in
                DetectionModel(
                    id: UUID().uuidString,
                    objName: result.labels.first?.identifier ?? "",
                    confidenceRate: result.confidence,
                    area: result.boundingBox
                )
            }
            
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffers)
        do {
            try requestHandler.perform([request])
        }catch {
            debugPrint("Error happend \(error)")
        }
        
    }
    
}

#Preview {
    LiveObjectDetectionView()
}
