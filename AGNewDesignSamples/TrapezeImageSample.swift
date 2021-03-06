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
    @IBOutlet weak var sampleImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()


        // trapezeImageView.image = trapezeImageView.image!.monochromeImage(color: UIColor.blue, intesity: 1)
        trapezeImageView.image!.monochrome(color: .blue) { self.trapezeImageView.image = $0 }

        trapezeImageView.leftSideRatio = 0.3
        trapezeImageView.rightSideRatio = 1

        sampleImage.applyTrapezeMask(leftSideRatio: 0.3, rightSideRatio: 1)
    }
}
