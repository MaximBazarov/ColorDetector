//
//  CaptureSession.swift
//  ColorDetector
//
//  Created by Maxim Bazarov on 4/4/18.
//  Copyright © 2018 Maxim Bazarov. All rights reserved.
//

import FunctionalFoundation
import AVFoundation

class CaptureSession {
    
    public static var initialization: Future<AVCaptureSession?> {
        return checkAuthorizationStatus()
            .then(selectDevice)
            .then(setupSession)
    }
    
    // MARK: - Utilites
    private static func checkAuthorizationStatus() -> Future<AVAuthorizationStatus> {
        let currentStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if currentStatus == .notDetermined { return authorize() }
        return Future(currentStatus)
    }
    
    private static func authorize() -> Future<AVAuthorizationStatus> {
        return Future<AVAuthorizationStatus> { resolve in
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                let result: AVAuthorizationStatus = granted ? .authorized : .denied
                resolve(result)
            }
        }
    }
    
    private static func selectDevice(_ status: AVAuthorizationStatus) -> Future<AVCaptureDevice?> {
        guard status == .authorized else { return Future<AVCaptureDevice?>(nil) }
        let mediaType = AVMediaType.video
        let position = AVCaptureDevice.Position.back
        let devices = AVCaptureDevice.devices().filter { device in
            return device.hasMediaType(mediaType) && device.position == position
        }
        return Future(devices.first)
    }
    
    private static func setupSession(_ device: AVCaptureDevice?) -> Future<AVCaptureSession?> {

        guard let device = device
            , let input = try? AVCaptureDeviceInput(device: device)
            else { return Future<AVCaptureSession?>(nil) }
        
        return Future<AVCaptureSession?> { resolve in
            let session = AVCaptureSession()
            guard session.canAddInput(input) else { resolve(nil); return}
            session.addInput(input)
            session.sessionPreset = AVCaptureSession.Preset.medium
            resolve(session)
        }
    }
    
}
