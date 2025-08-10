//
//  ContentView.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 10/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        VStack {
            if let img = capturedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(Text("No photo yet"))
            }
            
            NavigationLink("Open Camera") {
                CustomCameraView(onCapture: capturedImageHandler)
                
            }
            
        }
        .frame(maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .colorScheme(.light)
        .background(Color.white)
        .padding(.vertical).background(Color.white)
        
    }
    
    // Helper: search view controller tree for CameraViewController
    private func findCameraController(in vc: UIViewController) -> CustomCameraViewController? {
        if let c = vc as? CustomCameraViewController { return c }
        for child in vc.children {
            if let found = findCameraController(in: child) { return found }
        }
        if let presented = vc.presentedViewController {
            if let found = findCameraController(in: presented) { return found }
        }
        return nil
    }
    
    func capturedImageHandler(_ image: UIImage?) {
        capturedImage = image
    }
    
}


#Preview {
    ContentView()
}
