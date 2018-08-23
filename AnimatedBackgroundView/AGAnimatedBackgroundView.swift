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

    public var symbolColor: UIColor? { didSet { animationLayer.symbolColor = symbolColor }}
    private var symbolSize: CGFloat = 18 { didSet { animationLayer.symbolSize = symbolSize }}
    private var rowHeight: CGFloat = 40 { didSet { animationLayer.rowHeight = rowHeight }}
    public var symbolAngles: [[CGFloat]] = [[0]] { didSet { animationLayer.symbolsAngles = symbolAngles }}

    private var kindOfAnimation: AGBackgroundAnimationKind = .stop

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
            animationLayer.animate(kindOfAnimation)
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
    }

    public func startAnimation(_ kindOfAnimation: AGBackgroundAnimationKind) {
        self.kindOfAnimation = kindOfAnimation
        animationInProcess = true
        animationLayer?.animate(kindOfAnimation)
    }

    public func stopAnimation() {
        kindOfAnimation = .stop
        animationLayer?.animate(.stop)
    }
}

