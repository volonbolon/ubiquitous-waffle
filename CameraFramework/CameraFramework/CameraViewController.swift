//
//  CameraViewController.swift
//  CameraFramework
//
//  Created by Ariel Rodriguez on 01/12/2017.
//  Copyright © 2017 Ariel Rodriguez. All rights reserved.
//

import UIKit
import AVFoundation

public final class CameraViewController: UIViewController {
    fileprivate var camera: Camera?
    open var position: CameraPosition = .back {
        didSet {
            guard let camera = self.camera else {
                return
            }
            camera.position = position
        }
    }

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

    /**
     Loads the camera view finder
     */
    func createUI() {
        guard let previewLayer = self.camera?.getPreviewLayer() else {
            return
        }
        self.view.layer.addSublayer(previewLayer)
    }
}
