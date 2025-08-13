//
//  ContentView.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 10/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var presentDetectionView = false
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
            
            Button("Open Camera") {
                presentDetectionView = true
            }
            .buttonStyle(.bordered)
            
            NavigationLink(isActive: $presentDetectionView) {
                LiveObjectDetectionView()
                
            } label: {
                EmptyView()
            }

            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .colorScheme(.light)
        .background(Color.white)
        
    }
    
    func capturedImageHandler(_ image: UIImage?) {
        capturedImage = image
    }
    
}


#Preview {
    ContentView()
}
