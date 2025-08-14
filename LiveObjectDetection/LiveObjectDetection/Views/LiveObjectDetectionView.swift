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
    @StateObject var vm = LiveDetectionViewModel()
    
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
        .colorScheme(.light)
        .background(Color.appBlack)
        
    }
    
    var overlayingView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(vm.detectedObjects, id: \.id) { object in
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
                    
                    Text(object.objName + " - " + object.confidenceRate.perchentage)
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

    private func capturedPixelsHandler(_ pixelBuffers: CVPixelBuffer) {
        debugPrint("Captured Buffer Pixels at \(Date())")
        vm.requestDetection(pixelBuffers)
        
    }
    
}

#Preview {
    LiveObjectDetectionView()
}
