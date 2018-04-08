//
//  CaptureService.swift
//  ColorDetector
//
//  Created by Maxim Bazarov on 4/4/18.
//  Copyright © 2018 Maxim Bazarov. All rights reserved.
//

import AVFoundation
import FunctionalFoundation

class CaptureService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public let imagesStream: Observable<UIImage?>
    let previewLayer: AVCaptureVideoPreviewLayer
    
    static func startSession( preview frame: CGRect)  -> Future<CaptureService?> {
        return Future<CaptureService?> { resolve in
            CaptureSession.initialization.onComplete { session in
                guard let session = session else { resolve(nil); return }
                // setup capturing
                let service = CaptureService(session: session, previewframe: frame)
                let output = AVCaptureVideoDataOutput()
                output.setSampleBufferDelegate(service, queue: CaptureService.capturingQueue)
                guard session.canAddOutput(output) else { resolve(nil); return }
                session.addOutput(output)
                //orientation
                guard let connection = output.connection(with: AVFoundation.AVMediaType.video) , connection.isVideoOrientationSupported
                    , connection.isVideoMirroringSupported else { resolve(nil); return }
                connection.videoOrientation = .portrait
                resolve(service)
            }
        }
    }
    
    
    func stop() {
        session.stopRunning()
    }
    
    //MARK: Implementation
    
    private let context = CIContext()
    private var session: AVCaptureSession

    private init(session: AVCaptureSession, previewframe: CGRect) {
        self.session = session
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame.size = previewframe.size
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.session.startRunning()
        // setup streaming
        imagesStream = Observable<UIImage?>(nil)
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    
    var lastCapture = Date()
    private static let capturingQueue = DispatchQueue(label: "capturing queue")
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let now = Date()
        guard now.timeIntervalSince(lastCapture) > 5 else { return }
        guard let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        imagesStream.value = image
        lastCapture = now
    }
}

