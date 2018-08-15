//
//  ProgressBarSample.swift
//  AGNewDesignSamples
//
//  Created by Alexander Smetannikov on 14/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

class ProgressBarSample: UIViewController {

    @IBOutlet weak var progressBar1: GradientProgressBar!
    @IBOutlet weak var progressBar2: GradientProgressBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        progressBar1.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
        progressBar1.barColors = [UIColor(red: 81/255, green: 197/255, blue: 148/255, alpha: 1), UIColor(red: 207/255, green: 228/255, blue: 115/255, alpha: 1)]
        progressBar1.progress = 0

        progressBar2.backgroundColor = .white
        progressBar2.barColors = [UIColor(red: 240/255, green: 84/255, blue: 140/255, alpha: 1), UIColor(red: 247/255, green: 153/255, blue: 166/255, alpha: 1)]
        progressBar2.borderColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
        progressBar2.borderWidth = 2
        progressBar2.progress = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        progressBar1.setProgress(0.5, withDuration: 0.0)
        progressBar2.setProgress(0.8, withDuration: 0.0)
    }

}
