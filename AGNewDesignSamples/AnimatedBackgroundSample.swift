//
//  AnimatedBackgroundSample.swift
//  AGNewDesignSamples
//
//  Created by Alexander Smetannikov on 17/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

class AnimatedBackgroundSample: UIViewController {

    @IBOutlet weak var animatedBackgroundPink: AGAnimatedBackgroundView!

    @IBOutlet weak var animatedBackgroundGreen: AGAnimatedBackgroundView!

    override func viewDidLoad() {
        super.viewDidLoad()

        animatedBackgroundPink.appplyTrapezeMask(leftSideRatio: 0.3, rightSideRatio: 1)
        animatedBackgroundPink.symbolsColor = UIColor(red: 245/255, green: 106/255, blue: 159/255, alpha: 1)
        animatedBackgroundPink.startAnimation()

        animatedBackgroundGreen.appplyTrapezeMask(leftSideRatio: 0.3, rightSideRatio: 1)
        animatedBackgroundGreen.symbolsColor = UIColor(red: 34/255, green: 119/255, blue: 99/255, alpha: 1)
        animatedBackgroundGreen.startAnimation()
    }
}
