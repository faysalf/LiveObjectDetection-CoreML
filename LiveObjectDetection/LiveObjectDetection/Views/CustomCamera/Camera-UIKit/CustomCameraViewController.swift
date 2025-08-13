//
//  CustomCameraViewController.swift
//  LiveObjectDetection
//
//  Created by Md. Faysal Ahmed on 10/8/25.
//

import UIKit
import AVFoundation
import Photos

final class CustomCameraViewController: UIViewController {

    var onCapturedImage: ((UIImage?) -> Void)?
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var previewSuperView: UIView!
    
    // Life cycles
    override
    func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        checkPermissionsAndConfigure()
    }
    
    override
    func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override
    func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer?.frame = previewSuperView.bounds
    }
    
    // configuration
    private func configureSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        guard let camera = getBackCamera(),
              let input = try? AVCaptureDeviceInput(device: camera),
              captureSession.canAddInput(input)
        else {
            captureSession.commitConfiguration()
            onCapturedImage?(nil)
            return
        }
        captureSession.addInput(input)
        photoOutput = AVCapturePhotoOutput()
        
        let device = UIScreen.main.bounds
//        photoOutput.maxPhotoDimensions = CMVideoDimensions(
//            width: Int32(device.width),
//            height: Int32(device.height)
//        )
        if captureSession.canAddOutput(photoOutput) { captureSession.addOutput(photoOutput) }
        
        captureSession.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewSuperView.layer.insertSublayer(previewLayer, at: 0)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
        
    }
    
    @IBAction
    private func backAction(_ sender: UIButton) {
        //navigationController?.popViewController(animated: true)
        capturePhoto()
    }
    
    func capturePhoto() {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)

    }
    
    deinit {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
}

// MARK: - AVCapturePhotoCaptureDelegate & Other methods
extension CustomCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            print("Photo capture error:", error.localizedDescription)
            onCapturedImage?(nil)
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            onCapturedImage?(nil)
            return
        }
        
//        PHPhotoLibrary.requestAuthorization { status in
//            if status == .authorized {
//                PHPhotoLibrary.shared().performChanges {
//                    PHAssetChangeRequest.creationRequestForAsset(from: image)
//                }
//            }
//        }
        
        onCapturedImage?(image)
    }
    
}

// MARK: - Methods
extension CustomCameraViewController {
    static func getViewController() -> CustomCameraViewController {
        UIStoryboard(name: "CustomCameraViewController", bundle: nil)
            .instantiateViewController(withIdentifier: "CustomCameraViewControllerID") as! CustomCameraViewController
    }
    
    // checking camera permission
    private func checkPermissionsAndConfigure() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { self.configureSession() }
                    else { self.onCapturedImage?(nil) }
                }
            }
        default:
            onCapturedImage?(nil)
        }
    }

    func getBackCamera() -> AVCaptureDevice? {
        captureSession.sessionPreset = .photo
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
        return nil
    }
    
}

