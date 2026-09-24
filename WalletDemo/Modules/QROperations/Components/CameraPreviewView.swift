//
//  CameraPreviewView.swift
//  WalletDemo
//
//  Created by Uziel Sabalza on 23/9/26.
//


import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    var onQRCodeDetected: (String) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return view }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return view }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else { return view }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            // Especificamos que únicamente nos interesa buscar códigos QR
            metadataOutput.metadataObjectTypes = [.qr]
        } else { return view }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Correr la sesión en un hilo secundario para no congelar la UI de SwiftUI
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onQRCodeDetected: onQRCodeDetected)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var onQRCodeDetected: (String) -> Void
        
        init(onQRCodeDetected: @escaping (String) -> Void) {
            self.onQRCodeDetected = onQRCodeDetected
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                
                // Retroalimentación háptica nativa al detectar con éxito (HIG)
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                DispatchQueue.main.async {
                    self.onQRCodeDetected(stringValue)
                }
            }
        }
    }
}
