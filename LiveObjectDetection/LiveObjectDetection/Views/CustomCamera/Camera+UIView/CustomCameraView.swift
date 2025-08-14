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
    var capturedPixels: ((CVPixelBuffer)-> Void)?
    private var session: AVCaptureSession!
    private var videoOutput: AVCaptureVideoDataOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var lastFrameTime: CFAbsoluteTime = 0
    private var timeInterval: CFAbsoluteTime = 0.3
    
    override
    init(frame: CGRect) {
        super.init(frame: frame)
        checkPermissionAndConfigure()
    }
    
    required
    init?(coder: NSCoder) {
        super.init(coder: coder)
        checkPermissionAndConfigure()
    }
    
    override
    func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
    
    private func configure() {
        session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        
        session.addInput(input)
        videoOutput = AVCaptureVideoDataOutput()
        
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            session.addOutput(videoOutput)
        }
        
        // Ensuring pixel buffer is in right orientation
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        
    }
    
}

// MARK: - Video pixel buffer Delegate
extension CustomCameraUIView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastFrameTime >= timeInterval,
           let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) { //pass pixels after a specific preriod
            lastFrameTime = now
            self.capturedPixels?(pixelBuffer)

        }
        
    }
    
}

// MARK: - Methods
extension CustomCameraUIView {
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    private func checkPermissionAndConfigure() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configure()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
                if isGranted {
                    DispatchQueue.main.async {
                        self?.configure()
                    }
                }
            }
        default:
            debugPrint("Camera access denied")
        }
        
    }
    
}


// MARK: - Camera View Representable
struct CustomCameraPreview: UIViewRepresentable {
    var cameraView: CustomCameraUIView
    var capturedPixels: ((CVPixelBuffer)-> Void)?

    func makeUIView(context: Context) -> CustomCameraUIView {
        cameraView.capturedPixels = capturedPixels
        
        return cameraView
    }
    
    func updateUIView(_ uiView: CustomCameraUIView, context: Context) {}
    
}

