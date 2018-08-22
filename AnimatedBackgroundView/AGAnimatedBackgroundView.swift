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
    private let animationCycleDuration: CFTimeInterval = 1
    public var symbolColor: UIColor?
    private let symbolSize: CGFloat = 18
    private let rowHeight: CGFloat = 40
    public var symbolAngles: [[CGFloat]] = [[0]]

    private var kindAnimation: AnimationKind = .scrollUp

    private func initAnimationLayer() {
        layer.sublayers?.removeAll()
        
        animationLayer = AGAnimatedBackgroundLayer(
            frame: bounds,
            backgroundColor: backgroundColor ?? .white,
            rowHeight: rowHeight,
            symbolSize: symbolSize,
            symbolColor: symbolColor ?? .black,
            symbolsAngles: symbolAngles
        )

        layer.addSublayer(animationLayer)
        if animationInProcess {
            animationLayer.animate(kindOfAnimation: kindAnimation)
        } else {
            animationLayer.stop()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initAnimationLayer()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initAnimationLayer() 
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        animationLayer.frame = self.bounds
        initAnimationLayer()
    }

    public func startAnimation(_ kindAnimation: AnimationKind) {
        self.kindAnimation = kindAnimation
        animationInProcess = true
        animationLayer?.animate(kindOfAnimation: kindAnimation)
    }

    public func stopAnimation() {
        kindAnimation = .stop
        animationLayer?.animate(kindOfAnimation: .stop)
    }

}
