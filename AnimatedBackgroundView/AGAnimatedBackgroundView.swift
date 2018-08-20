//
//  AGAnimatedBackgroundView.swift
//
//  Created by Alexander Smetannikov on 17/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

public class AGAnimatedBackgroundView: UIView {
    private var animationLayer: AGAnimatedBackgroundLayer!
    private var animationInProcess: Bool = false
    public var symbolsColor: UIColor?
    private let symbolSize: CGFloat = 18
    private let rowHeight: CGFloat = 40

    private func initAnimationLayer() {
        layer.sublayers?.removeAll()
        
        animationLayer = AGAnimatedBackgroundLayer(
            frame: bounds,
            backgroundColor: backgroundColor ?? .white,
            rowHeight: rowHeight,
            symbolSize: symbolSize,
            symbolColor: symbolsColor ?? .black)

        layer.addSublayer(animationLayer)
        if animationInProcess {
            animationLayer.animate()
        } else {
            animationLayer.removeAllAnimations()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        initAnimationLayer()
    }

    public func startAnimation() {
        animationInProcess = true
        animationLayer?.animate()
    }

}
