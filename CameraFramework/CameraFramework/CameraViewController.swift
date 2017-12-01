//
//  CameraViewController.swift
//  CameraFramework
//
//  Created by Ariel Rodriguez on 01/12/2017.
//  Copyright © 2017 Ariel Rodriguez. All rights reserved.
//

import UIKit
import AVFoundation

public enum CameraPosition {
    case front
    case back
}

public final class CameraViewController: UIViewController {
    public var position: CameraPosition = .back

    var session = AVCaptureSession()
    var discoverySession: AVCaptureDevice.DiscoverySession? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                mediaType: AVMediaType.video,
                                                position: AVCaptureDevice.Position.unspecified)
    }
    var videoInput: AVCaptureDeviceInput?
    var videoOutput = AVCaptureVideoDataOutput()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.createUI()
        self.commitConfiguration()
    }
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     Loads the camera view finder
     */
    func createUI() {
        let previewLayer = self.getPreviewLayer(session: self.session)
        self.view.layer.addSublayer(previewLayer)
    }

    func commitConfiguration() {
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
            print("Error linking device to AVInput!")
            return
        }
    }

    /**
     - parameter session: A discovery session to fetch the required device
     - returns: the viewfinder
     */
    func getPreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return previewLayer
    }

    /**
     - parameter session: A discovery session to fetch the required device
     - returns: the available device for the capture session
     */
    func getDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        guard let discoverySession = self.discoverySession else {
            return nil
        }

        var device: AVCaptureDevice? = nil
        for discoveredDevice in discoverySession.devices where discoveredDevice.position == position {
            device = discoveredDevice
        }

        return device
    }
}
