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
            NavigationLink {
                LiveObjectDetectionView()
                
            } label: {
                Text("Start Detection")
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color.gray.opacity(0.5))
                    .clipShape(Capsule())
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
