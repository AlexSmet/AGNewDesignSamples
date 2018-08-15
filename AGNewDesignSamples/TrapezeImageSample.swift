//
//  TrapezeImageSample.swift
//  AGNewDesignSamples
//
//  Created by Alexander Smetannikov on 14/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

class TrapezeImageSample: UIViewController {

    @IBOutlet weak var trapezeImageView: TrapezeImageView!

    override func viewDidLoad() {
        super.viewDidLoad()


        // trapezeImageView.image = trapezeImageView.image!.monochromeImage(color: UIColor.blue, intesity: 1)
        trapezeImageView.image!.monochromeImage(color: .blue) { self.trapezeImageView.image = $0 }

        trapezeImageView.leftSideRatio = 0.3
        trapezeImageView.rightSideRatio = 1
    }
}
