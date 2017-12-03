//
//  ViewController.swift
//  SampleCameraFramework
//
//  Created by Ariel Rodriguez on 01/12/2017.
//  Copyright © 2017 Ariel Rodriguez. All rights reserved.
//

import UIKit
import CameraFramework

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("framework version: \(CameraViewController.versionNumber!)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - IBActions
    @IBAction func startButtonTapped(_ sender: Any) {
        let camera = CameraViewController()
        camera.delegate = self
        camera.position = CameraPosition.back
        self.present(camera, animated: true, completion: nil)
    }
}

extension ViewController: CameraControllerDelegate {
    func stillImageCaptured(controller: CameraViewController, image: UIImage) {
        self.imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }

    func cancelButtonTapped(controller: CameraViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
