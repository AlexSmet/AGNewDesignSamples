//
//  SHGradientProgressBar.swift
//  SimpleTest
//
//  Created by Alexander Smetannikov on 27/07/2018.
//  Copyright © 2018 AlexSmetannikov. All rights reserved.
//

import UIKit

class GradientProgressBar: UIView, CAAnimationDelegate {

    var barColors: [UIColor] {
        get { return gradientLayer.barColors.map { UIColor(cgColor: $0) } }
        set { gradientLayer.barColors = newValue.map { $0.cgColor } }
    }

    var borderColor: UIColor? {
        get { return gradientLayer.aBorderColor == nil ? nil: UIColor(cgColor: gradientLayer.aBorderColor!) }
        set { gradientLayer.aBorderColor = newValue?.cgColor }
    }

    var borderWidth: CGFloat {
        get { return gradientLayer.aBorderWidth }
        set { gradientLayer.aBorderWidth = newValue }
    }

    var barTipAngle: CGFloat {
        get { return gradientLayer.barTipAngle }
        set { gradientLayer.barTipAngle = newValue }
    }

    @objc dynamic var progress: CGFloat = 0.0 {
        didSet {
            gradientLayer.progress = progress
        }
    }

    func setProgress(_ progress: CGFloat, withDuration: Double, complition: ((Bool) -> Void)? = nil) {
        onAnimationComplition = complition
        let animation = CABasicAnimation(keyPath: "progress")
        animation.fromValue = CGFloat(0.0)
        animation.toValue = progress
        animation.duration = withDuration
        animation.delegate = self
        layer.add(animation, forKey: "progress")
        gradientLayer.progress = progress
    }

    override class var layerClass: AnyClass {
        return GradientLayer.self
    }

    var gradientLayer: GradientLayer {
        return self.layer as! GradientLayer
    }

    private var onAnimationComplition: ((Bool) -> Void)?

    func animationDidStop(_ animation: CAAnimation, finished: Bool) {
        onAnimationComplition?(finished)
    }

    override var frame: CGRect {
        didSet {
            layer.setNeedsDisplay()
        }
    }
}

class GradientLayer: CAShapeLayer {
    var barTipAngle: CGFloat = 60
    @NSManaged var barColors: [CGColor]
    @NSManaged var progress: CGFloat
    @NSManaged var aBorderColor: CGColor?
    @NSManaged var aBorderWidth: CGFloat

    private var gradientTailLength: CGFloat {
        return bounds.height / tan(barTipAngle * CGFloat.pi / 180)
    }

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }

    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)

        UIGraphicsPushContext(ctx)

        var tailLength = gradientTailLength
        if progress == 0 || progress == 1 {
            tailLength = 0
        }

        let progressLength = bounds.width * progress
        let width = bounds.width
        let height = bounds.height

        // Draw border
        if let borderColor1 = aBorderColor {
            let borderPath = UIBezierPath()
            UIColor(cgColor: borderColor1).setStroke()
            borderPath.lineWidth = aBorderWidth
            let borderWidth2 = aBorderWidth / 2
            if progress == 0 {
                borderPath.move(to: CGPoint(x: progressLength - tailLength + borderWidth2, y: height - borderWidth2))
                borderPath.addLine(to: CGPoint(x: progressLength - tailLength + borderWidth2, y: borderWidth2))
            } else {
                borderPath.move(to: CGPoint(x: progressLength - tailLength, y: borderWidth2))
            }
            borderPath.addLine(to: CGPoint(x: width - borderWidth2, y: borderWidth2))
            borderPath.addLine(to: CGPoint(x: width - borderWidth2, y: height - borderWidth2))
            borderPath.addLine(to: CGPoint(x: progressLength - borderWidth2, y: height - borderWidth2))
            borderPath.stroke()
            borderPath.close()
        }

        // Draw gradient
        let gradientPath = UIBezierPath()
        gradientPath.move(to: CGPoint(x: 0, y: 0))
        gradientPath.addLine(to: CGPoint(x: progressLength - tailLength, y: 0))
        gradientPath.addLine(to: CGPoint(x: progressLength, y: height))
        gradientPath.addLine(to: CGPoint(x: 0, y: height))
        gradientPath.addLine(to: CGPoint(x: 0, y: 0))
        gradientPath.addClip()
        gradientPath.close()

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: barColors as CFArray, locations: colorLocations)!

        ctx.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: bounds.width * progress, y: 0), options: [])

        UIGraphicsPopContext()
    }
}
