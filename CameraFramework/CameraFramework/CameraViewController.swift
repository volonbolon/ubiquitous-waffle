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
        let x = self.view.frame.minX + 10
        let y = self.view.frame.maxY - 50
        let frame = CGRect(x: x, y: y, width: 70, height: 30)
        let button = UIButton(frame: frame)

        let title = NSLocalizedString("Cancel", comment: "Cancel")
        button.setTitle(title, for: .normal)

        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        self._cancelButton = button
        return button
    }
    open weak var delegate: CameraControllerDelegate?

    public init() {
        super.init(nibName: nil, bundle: nil)
        self.camera = Camera(with: self)
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
        self.view.layer.addSublayer(previewLayer)

        self.view.addSubview(self.cancelButton)
    }
}

// MARK: - IBActions
fileprivate extension CameraViewController {
    @IBAction func cancelButtonTapped(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.cancelButtonTapped(controller: self)
        }
    }
}
