//
//  AGAnimatedBackgroundView.swift
//
//  Created by Alexander Smetannikov on 17/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

public class AGAnimatedBackgroundView: UIView {
    private var animationLayer: AGAnimatedBackgroundLayer!

    public var symbolColor: UIColor? { didSet { animationLayer.symbolColor = symbolColor }}
    private var symbolSize: CGFloat = 18 { didSet { animationLayer.symbolSize = symbolSize }}
    private var rowHeight: CGFloat = 40 { didSet { animationLayer.rowHeight = rowHeight }}
    public var symbolAngles: [[CGFloat]] = [[0]] { didSet { animationLayer.symbolsAngles = symbolAngles }}

    private func initAnimationLayer() {
        animationLayer = AGAnimatedBackgroundLayer(
            frame: bounds,
            backgroundColor: backgroundColor ?? .white,
            rowHeight: rowHeight,
            symbolSize: symbolSize,
            symbolColor: symbolColor ?? .black,
            symbolsAngles: symbolAngles
        )

        layer.addSublayer(animationLayer)
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
        animationLayer.animate(kindOfAnimation)
    }

    public func stopAnimation() {
        animationLayer.animate(.stop)
    }

    public func exchangeTo(backgroundColor: UIColor, symbolColor: UIColor) {
        stopAnimation()

        self.backgroundColor = backgroundColor
        let newAnimationLayer = AGAnimatedBackgroundLayer(
            frame: bounds,
            backgroundColor: backgroundColor,
            rowHeight: rowHeight,
            symbolSize: symbolSize,
            symbolColor: symbolColor,
            symbolsAngles: symbolAngles
        )

        let maskLayer = ExchangeMaskLayer.init(frame: bounds)
        newAnimationLayer.mask = maskLayer
        layer.addSublayer(newAnimationLayer)

        maskLayer.animate() { [weak self] in
            newAnimationLayer.mask = nil
            self?.animationLayer.removeFromSuperlayer()
            self?.animationLayer = newAnimationLayer
        }
    }
}

private class ExchangeMaskLayer: CAShapeLayer, CAAnimationDelegate {

    let rightSideRatio: CGFloat = 0.3
    private var width: CGFloat { return frame.size.width }
    private var height: CGFloat { return frame.size.height }

    private var animationComplition: (()-> Void)?

    init(frame: CGRect) {
        super.init()
        self.frame = frame
        path = getBeginMask()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getBeginMask() -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -width*rightSideRatio*2))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: -width*rightSideRatio))
        path.addLine(to: CGPoint(x: width, y: -width*rightSideRatio*2))
        path.addLine(to: CGPoint(x: 0, y: 0))

        return path.cgPath
    }

    private func getFinalMask() -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))

        return path.cgPath
    }

    func animate(complition: (()-> Void)? = nil) {
        removeAllAnimations()
        animationComplition = complition
        let animation = CABasicAnimation(keyPath: "path")
        animation.delegate = self
        animation.duration = 1
        animation.toValue = getFinalMask()
        add(animation, forKey: "exchangeLayers")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else {
            return
        }
        animationComplition?()
    }
}

