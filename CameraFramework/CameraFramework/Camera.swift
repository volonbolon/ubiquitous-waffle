//
//  Camera.swift
//  CameraFramework
//
//  Created by Ariel Rodriguez on 02/12/2017.
//  Copyright © 2017 Ariel Rodriguez. All rights reserved.
//

import UIKit
import AVFoundation

public enum CameraPosition {
    case front
    case back
}

protocol CameraDelegate: class {
    func stillImageCaptured(camera: Camera, image: UIImage)
}

class Camera: NSObject {
    weak var delegate: CameraDelegate?
    var position = CameraPosition.back {
        didSet {
            if self.session.isRunning {
                self.session.stopRunning()

                self.update()
            }
        }
    }
    var controller: CameraViewController?
    fileprivate var session = AVCaptureSession()
    fileprivate var discoverySession: AVCaptureDevice.DiscoverySession? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                mediaType: AVMediaType.video,
                                                position: AVCaptureDevice.Position.unspecified)
    }
    var videoInput: AVCaptureDeviceInput?
    var videoOutput = AVCaptureVideoDataOutput()
    var photoOutput = AVCapturePhotoOutput()

    required init(with controller: CameraViewController) {
        self.controller = controller
    }

    func captureStillImage() {
        let settings = AVCapturePhotoSettings()
        self.photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func update() {
        self.recycleDeviceIO()
        guard let input = self.getNewInputDevice() else {
            return
        }
        let canAddInput = self.session.canAddInput(input)
        let canAddOutput = self.session.canAddOutput(self.videoOutput)
        let canAddPhotoOutput = self.session.canAddOutput(self.photoOutput)

        guard canAddInput, canAddOutput, canAddPhotoOutput else {
            return
        }
        self.videoInput = input

        self.session.addInput(input)
        self.session.addOutput(self.videoOutput)
        self.session.addOutput(self.photoOutput)

        self.session.commitConfiguration()

        self.session.startRunning()
    }

    /**
     - parameter session: A discovery session to fetch the required device
     - returns: the viewfinder
     */
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        guard let controller = self.controller else {
            return nil
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.frame = controller.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        return previewLayer
    }
}

// MARK: - CaptureDevice Handling
private extension Camera {
    /**
     - parameter session: A discovery session to fetch the required device
     - returns: the available device for the capture session
     */
    private func getDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        guard let discoverySession = self.discoverySession else {
            return nil
        }

        for device in discoverySession.devices where device.position == position {
            return device
        }

        return nil
    }

    func getNewInputDevice() -> AVCaptureDeviceInput? {
        do {
            let position = self.position == .front ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
            guard let device = self.getDevice(with: position) else {
                return nil
            }
            let input = try AVCaptureDeviceInput(device: device)
            return input
        } catch {
            return nil
        }
    }

    func recycleDeviceIO() {
        for oldInput in self.session.inputs {
            self.session.removeInput(oldInput)
        }
        for oldOutput in self.session.outputs {
            self.session.removeOutput(oldOutput)
        }
    }
}

// MARK: - Still Photo Capture
extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let image = photo.normalizedImage(forCameraPosition: self.position) else {
            return
        }
        if let delegate = self.delegate {
            delegate.stillImageCaptured(camera: self, image: image)
        }
    }
}

extension AVCapturePhoto {
    func normalizedImage(forCameraPosition position: CameraPosition) -> UIImage? {
        guard let cgImage = self.cgImageRepresentation() else {
            return nil
        }
        let imageOrientation = self.getImageOrientation(forCamera: position)
        let image = UIImage(cgImage: cgImage.takeUnretainedValue(), scale: 1.0, orientation: imageOrientation)
        return image
    }

    private func getImageOrientation(forCamera: CameraPosition) -> UIImageOrientation {
        var orientation: UIImageOrientation
        let appOrientation = UIApplication.shared.statusBarOrientation
        switch appOrientation {
        case .landscapeLeft:
            orientation = forCamera == .back ? .down : .upMirrored
        case .landscapeRight:
            orientation = forCamera == .back ? .up : .downMirrored
        case .portraitUpsideDown:
            orientation = forCamera == .back ? .left : .rightMirrored
        case .portrait, .unknown:
            orientation = forCamera == .back ? .right : .leftMirrored
        }
        return orientation
    }
}
