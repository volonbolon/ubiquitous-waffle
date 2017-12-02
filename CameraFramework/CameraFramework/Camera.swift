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

class Camera: NSObject {
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

    required init(with controller: CameraViewController) {
        self.controller = controller
    }

    /**
     - parameter session: A discovery session to fetch the required device
     - returns: the available device for the capture session
     */
    private func getDevice(with position:AVCaptureDevice.Position) -> AVCaptureDevice? {
        guard let discoverySession = self.discoverySession else {
            return nil
        }

        for device in discoverySession.devices where device.position == position {
            return device
        }

        return nil
    }

    func update() {
        if let currentInput = self.videoInput {
            self.session.removeInput(currentInput)
            self.session.removeOutput(self.videoOutput)
        }
        do {
            let position = self.position == .front ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
            guard let device = self.getDevice(with: position) else {
                return
            }
            let input = try AVCaptureDeviceInput(device: device)
            let canAddInput = self.session.canAddInput(input)
            let canAddOutput = self.session.canAddOutput(self.videoOutput)
            if canAddInput && canAddOutput {
                self.videoInput = input

                self.session.addInput(input)
                self.session.addOutput(self.videoOutput)

                self.session.commitConfiguration()

                self.session.startRunning()
            }
        } catch {
            print("Unable to update the session")
        }
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
