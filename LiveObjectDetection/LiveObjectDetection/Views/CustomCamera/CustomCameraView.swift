//
//  CustomCameraView.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 10/8/25.
//

import SwiftUI
import AVFoundation
import Photos

struct CustomCameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CustomCameraViewController
    
    var onCapture: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> CustomCameraViewController {
        let vc = CustomCameraViewController.getViewController()
        vc.onCapturedImage = onCapture
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CustomCameraViewController, context: Context) {}
    
}

