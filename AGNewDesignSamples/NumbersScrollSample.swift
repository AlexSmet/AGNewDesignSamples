//
//  NumbersScrollSample.swift
//  AGNewDesignSamples
//
//  Created by Alexander Smetannikov on 14/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

class NumbersScrollSample: UIViewController {

    @IBOutlet weak var animatedNumbers: SHNumbersScrollAnimatedView!

    override func viewDidLoad() {
        super.viewDidLoad()

        animatedNumbers.textColor = .white
        animatedNumbers.font = UIFont.boldSystemFont(ofSize: 64)

        animatedNumbers.durationOffsetRule = { (_, _) in return 0 }
        animatedNumbers.animationDuration = 3

        animatedNumbers.value = "220 586"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animatedNumbers.startAnimation()
    }
}
