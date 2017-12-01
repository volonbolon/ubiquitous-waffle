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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let camera = CameraViewController()
        camera.position = CameraPosition.back
        self.present(camera, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

