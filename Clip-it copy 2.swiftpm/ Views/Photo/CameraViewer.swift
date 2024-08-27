//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 07/02/24.
//

import SwiftUI
import AVFoundation

class CameraController: ObservableObject {
    var cameraViewController: CameraViewController?
    
    func updateFrameSize(newSize: CGRect) {
        withAnimation {
            cameraViewController?.previewLayer?.frame = newSize
        }
    }
    
    func takePicture(flashMode: AVCaptureDevice.FlashMode, pictureCompletionHandler: @escaping (String)->Void) {
        cameraViewController?.takePicture(flashMode: flashMode, pictureCompletionHandler: pictureCompletionHandler)
    }
    
    func startCamera() {
        cameraViewController?.captureSession?.startRunning()
    }
    
    func disableCamera() {
        cameraViewController?.captureSession?.stopRunning()
    }
}

struct CameraPreviewView: UIViewControllerRepresentable {
    @ObservedObject var cameraController: CameraController
    @Binding var cameraPosition: AVCaptureDevice.Position
    @Binding var updatedSize: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = CameraViewController()
        viewController.cameraPosition = .back
        cameraController.cameraViewController = viewController
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if let viewController = uiViewController as? CameraViewController {
            viewController.switchCamera(to: cameraPosition)
        }
    }
}

class CameraViewController: UIViewController {
    var cameraPosition: AVCaptureDevice.Position = .back
    var captureSession: AVCaptureSession?
    var cameraViewerSession: AVCaptureVideoDataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput?
    
    private var pictureCompletionHandler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
    }
    
    func checkPermissions() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                setupCaptureSession()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { gaveAccess in
                    if (gaveAccess) {
                        self.setupCaptureSession()
                    } else {
                        // SHOW CONFIG, REMOVE ABILITY TO RECORD
                        print("DENIED")
                    }
                }
            case .denied:
                // SHOW CONFIG
                print("DENIED")
            case .restricted:
                print("RESTRICTED")
            @unknown default:
                break
            }
        }
    }
    
    func setupCaptureSession() {
        let videoCapture = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video, position: .back
        ).devices.first
        guard let videoCapture = videoCapture else { return }
        
        captureSession = AVCaptureSession()
        cameraViewerSession = AVCaptureVideoDataOutput()
        
        var deviceCameraInput: AVCaptureDeviceInput
        do {
            deviceCameraInput = try AVCaptureDeviceInput(device: videoCapture)
        } catch {
            return
        }
        
        captureSession?.beginConfiguration()
        captureSession?.sessionPreset = .high
        
        guard ((captureSession?.canAddInput(deviceCameraInput)) != nil) else {
            captureSession?.commitConfiguration()
            return
        }
        captureSession?.addInput(deviceCameraInput)
        
        guard ((captureSession?.canAddOutput(cameraViewerSession!)) != nil) else {
            captureSession?.commitConfiguration()
            return
        }
        captureSession?.addOutput(cameraViewerSession!)
        
        captureSession?.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        
        captureSession?.startRunning()
    }
    
    func switchCamera(to position: AVCaptureDevice.Position) {
        guard let captureSession = captureSession, let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        
        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        
        guard let newCamera = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video, position: position
        ).devices.first else {
            print("ERROR")
            return
        }
        
        guard let newInput = try? AVCaptureDeviceInput(device: newCamera) else { return }
        
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
        }
        
        captureSession.commitConfiguration()
    }
    
    func takePicture(flashMode: AVCaptureDevice.FlashMode, pictureCompletionHandler:@escaping (String)->Void) {
        self.pictureCompletionHandler = pictureCompletionHandler
        
        photoOutput = AVCapturePhotoOutput()
        
        if captureSession?.canAddOutput(photoOutput!) == true {
            captureSession?.addOutput(photoOutput!)
        }
        
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        savePhoto(imageData: imageData)
    }
    
    func savePhoto(imageData: Data) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        
        do {
            try imageData.write(to: fileURL)
            self.pictureCompletionHandler?(fileName)
        } catch {
            print("ERROR SAVING PHOTO")
            self.pictureCompletionHandler?("")
        }
    }
}
