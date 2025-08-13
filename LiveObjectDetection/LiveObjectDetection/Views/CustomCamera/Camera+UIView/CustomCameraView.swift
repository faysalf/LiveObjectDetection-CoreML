//
//  CustomCameraView.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 12/8/25.
//

import UIKit
import SwiftUI
import AVFoundation

class CustomCameraUIView: UIView {
    private var session: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        checkPermissionAndConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        checkPermissionAndConfigure()
    }
    
    private func configure() {
        session = AVCaptureSession()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = self.bounds
        self.layer.addSublayer(previewLayer)
        self.startSession()
    }
    
}

// Photo output delegate
extension CustomCameraUIView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            debugPrint("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        
        debugPrint("Photo captured at \(Date())")
        
    }
    
}

// Methods
extension CustomCameraUIView {
    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            self?.session.startRunning()
        }
        startTimer()
    }
    
    func stopSession() {
        stopTimer()
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.capturePhoto()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func checkPermissionAndConfigure() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configure()
            startSession()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
                if isGranted {
                    DispatchQueue.main.async {
                        self?.configure()
                        self?.startSession()
                    }
                }
            }
        default:
            print("Camera access denied")
        }
    }
    
}

// View Representable
struct CustomCameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let camView = CustomCameraUIView()
        
        return camView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
