//
//  LiveObjectDetectionView.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 11/8/25.
//

import SwiftUI
import Vision

struct LiveObjectDetectionView: View {
    @State private var showCamera = false
    let camera = CustomCameraUIView()
    
    var body: some View {
        ZStack {
            CustomCameraPreview(cameraView: camera, capturedPixels: capturedPixelsHandler)
                .onAppear {
                    camera.startSession()
                }
                .onDisappear {
                    camera.stopSession()
                }
        }
        .edgesIgnoringSafeArea(.all)
        
    }
    
    private func capturedPixelsHandler(pixels: CVPixelBuffer) {
        debugPrint("Captured Pixels: ", pixels.hashValue.words.count)
        
        
    }
}

#Preview {
    LiveObjectDetectionView()
}
