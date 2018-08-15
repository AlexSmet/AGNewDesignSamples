//
//  NumbersScrollSample.swift
//  AGNewDesignSamples
//
//  Created by Alexander Smetannikov on 14/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

class NumbersScrollSample: UIViewController {

    @IBOutlet weak var animatedNumbers: NumbersScrollAnimatedView!

    override func viewDidLoad() {
        super.viewDidLoad()

        animatedNumbers.textColor = .white
        animatedNumbers.font = UIFont.boldSystemFont(ofSize: 64)

        // animatedNumbers.animationDurationOffsetRule = { (_, _) in return 0 }
        // animatedNumbers.animationTimeOffsetRule = { (_, _) in return 0 }
        // animatedNumbers.scrollingDirectionRule = { (_, _) in return ScrollingDirection.down }
        // animatedNumbers.inverseSequenceRule = { (_, _) in return false }
        animatedNumbers.scrollingDirectionRule = { (_, index) in
            if index % 2 == 0 {
                return ScrollingDirection.down
            } else {
                return ScrollingDirection.up
            }
        }
        animatedNumbers.animationDuration = 3

        animatedNumbers.text = "222-222"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animatedNumbers.startAnimation()
    }
}
