//
//  LiveObjectDetectionView.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 11/8/25.
//

import SwiftUI

struct LiveObjectDetectionView: View {
    @State private var showCamera = false
    
    var body: some View {
        ZStack {
            if showCamera {
                CustomCameraPreview()
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.5), value: showCamera)
                
            } else {
                VStack {
                    Text("Tap to open camera")
                        .font(.headline)
                        .padding()
                    Button("Open Camera") {
                        withAnimation {
                            showCamera = true
                        }
                    }
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    LiveObjectDetectionView()
}
