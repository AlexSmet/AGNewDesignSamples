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

        animatedBackgroundPink.symbolColor = UIColor(red: 245/255, green: 106/255, blue: 159/255, alpha: 1)
        animatedBackgroundPink.startAnimation(.scrollDown)

        animatedBackgroundGreen.symbolColor = UIColor(red: 34/255, green: 119/255, blue: 99/255, alpha: 1)
        animatedBackgroundGreen.symbolAngles = [[90, 0], [179, 270]]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animatedBackgroundPink.applyTrapezeMask(leftSideRatio: 0.3, rightSideRatio: 1)
    }

    @IBAction func pushScrollingUpButton(_ sender: UIButton) {
        animatedBackgroundGreen.startAnimation(.scrollUp)
    }

    @IBAction func pushStopButton(_ sender: UIButton) {
        animatedBackgroundGreen.stopAnimation()
    }

    @IBAction func pushScrollingDown(_ sender: UIButton) {
        animatedBackgroundGreen.startAnimation(.scrollDown)
    }
}
