//
//  CameraViewController.swift
//  CameraFramework
//
//  Created by Ariel Rodriguez on 01/12/2017.
//  Copyright © 2017 Ariel Rodriguez. All rights reserved.
//

import UIKit
import AVFoundation

public protocol CameraControllerDelegate: class {
    func cancelButtonTapped(controller: CameraViewController)
    func stillImageCaptured(controller: CameraViewController, image: UIImage)
}

public final class CameraViewController: UIViewController {
    var previewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var camera: Camera?
    open var position: CameraPosition = .back {
        didSet {
            guard let camera = self.camera else {
                return
            }
            camera.position = position
        }
    }
    private var _cancelButton: UIButton?
    var cancelButton: UIButton {
        if let currentButton = self._cancelButton {
            return currentButton
        }
        let button = UIButton()
        let title = NSLocalizedString("Cancel", comment: "Cancel")
        button.setTitle(title, for: UIControlState.normal)

        button.addTarget(self, action: #selector(cancelButtonTapped), for: UIControlEvents.touchUpInside)
        self._cancelButton = button
        return button
    }
    private var _shutterButton: UIButton?
    var shutterButton: UIButton {
        if let shutterButton = self._shutterButton {
            return shutterButton
        }
        let button = UIButton()
        let bundle = Bundle(for: CameraViewController.self)
        let image = UIImage(named: "trigger", in: bundle, compatibleWith: nil)
        button.setImage(image, for: UIControlState.normal)
        button.addTarget(self, action: #selector(shutterButtonTapped), for: UIControlEvents.touchUpInside)
        self._shutterButton = button

        return button
    }
    open weak var delegate: CameraControllerDelegate?

    public init() {
        super.init(nibName: nil, bundle: nil)
        let camera = Camera()
        self.camera = camera
        camera.delegate = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let camera = self.camera else {
            return
        }
        self.createUI()
        camera.update()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let orientation = UIApplication.shared.statusBarOrientation
        self.updateUI(orientation: orientation)
        self.updateButtonFrames()
    }
}

// MARK: - Loads UI
fileprivate extension CameraViewController {
    /**
     Loads the camera view finder
     */
    func createUI() {
        guard let previewLayer = self.camera?.getPreviewLayer() else {
            return
        }
        self.previewLayer = previewLayer
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)

        self.view.addSubview(self.cancelButton)
        self.view.addSubview(self.shutterButton)
    }

    func updateUI(orientation: UIInterfaceOrientation) {
        guard let previewLayer = self.previewLayer, let connection = previewLayer.connection else {
            return
        }
        previewLayer.frame = self.view.bounds
        switch orientation {
        case .portrait:
            connection.videoOrientation = .portrait
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            connection.videoOrientation = .landscapeLeft
        case .landscapeRight:
            connection.videoOrientation = .landscapeRight
        default:
            connection.videoOrientation = .portrait
        }
    }

    private func updateCancelButtonFrame() {
        let x = self.view.frame.minX + 10
        let y = self.view.frame.maxY - 50
        let frame = CGRect(x: x, y: y, width: 70, height: 30)
        self.cancelButton.frame = frame
    }

    private func updateShutterButtonFrame() {
        let x = self.view.frame.midX - 35
        let y = self.view.frame.maxY - 80
        let frame = CGRect(x: x, y: y, width: 70, height: 70)
        self.shutterButton.frame = frame
    }

    func updateButtonFrames() {
        self.updateCancelButtonFrame()
        self.updateShutterButtonFrame()
    }
}

// MARK: - IBActions
fileprivate extension CameraViewController {
    @IBAction func cancelButtonTapped(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.cancelButtonTapped(controller: self)
        }
    }

    @IBAction func shutterButtonTapped(sender: UIButton) {
        if let camera = self.camera {
            camera.captureStillImage()
        }
    }
}

// MARK: - Semantic Version
public extension CameraViewController {
    public class var versionNumber: String? {
        let bundle = Bundle(for: CameraViewController.self)
        guard let info = bundle.infoDictionary, let versionString = info["CFBundleShortVersionString"] as? String else {
            return nil
        }
        return versionString
    }
}

// MARK: - CAmera Delegate functions
extension CameraViewController: CameraDelegate {
    func stillImageCaptured(camera: Camera, image: UIImage) {
        if let delegate = self.delegate {
            delegate.stillImageCaptured(controller: self, image: image)
        }
    }
}
