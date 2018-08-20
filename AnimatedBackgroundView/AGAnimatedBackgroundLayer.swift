//
//  AGAnimatedBackgroundLayer.swift
//
//  Created by Alexander Smetannikov on 17/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

class AGSymbolPath {
    static func getPath(withScale scale: CGFloat)-> UIBezierPath {
        let path = UIBezierPath()

        path.move(to: CGPoint(x: (4+31)*scale, y: 334*scale))
        path.addLine(to: CGPoint(x: (74+31)*scale, y: 317*scale))
        path.addLine(to: CGPoint(x: (139+31)*scale, y: 71*scale))
        path.addLine(to: CGPoint(x: (206+31)*scale, y: 317*scale))
        path.addLine(to: CGPoint(x: (274+31)*scale, y: 334*scale))
        path.addLine(to: CGPoint(x: (186+31)*scale, y: 6*scale))
        path.addLine(to: CGPoint(x: (92+31)*scale, y: 6*scale))
        path.addLine(to: CGPoint(x: (4+31)*scale, y: 334*scale))

        return path
    }
}

class AGSymbolLayer: CAShapeLayer {
    var symbolColor: UIColor

    init(symbolColor: UIColor) {
        self.symbolColor = symbolColor
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func draw(angle: CGFloat = 0) {
        path = getLetterPath().cgPath
        strokeColor = symbolColor.cgColor
        fillColor = symbolColor.cgColor
        lineWidth = 1

        if angle != 0 {
            let radians = angle * CGFloat.pi/180
            transform = CATransform3DMakeRotation(radians, 0, 0, 1)
        }
    }

    func rotate(angle: CGFloat, withDuration duration: CFTimeInterval) {
        rotate(startAngle: 0, finishAngle: angle, withDuration: duration)
    }

    func rotate(startAngle: CGFloat, finishAngle: CGFloat, withDuration duration: CFTimeInterval) {
        if duration > 0 {
            draw(angle: startAngle)

            let startAngleRadians = startAngle * CGFloat.pi/180
            let finishAngleRadians = finishAngle * CGFloat.pi/180
            let animation = CABasicAnimation(keyPath: "transform")
            animation.duration = duration
            animation.fromValue = startAngleRadians
            animation.toValue = finishAngleRadians
            animation.valueFunction = CAValueFunction(name: kCAValueFunctionRotateZ)

            add(animation, forKey: "rotation")

            transform = CATransform3DMakeRotation(finishAngleRadians, 0, 0, 1)
        } else {
            draw(angle: finishAngle)
        }
    }

    func getLetterPath()-> UIBezierPath {
        let scale: CGFloat = min(frame.width/340, frame.height/340)

        let path = AGSymbolPath.getPath(withScale: scale)

        return path
    }
}


class AGSymbolsRowLayer: CALayer {
    private var symbolLayers: [AGSymbolLayer] = []
    private var symbolSize: CGFloat

    init(frame: CGRect, symbolSize: CGFloat, symbolColor: UIColor) {
        self.symbolSize = symbolSize

        super.init()

        anchorPoint = CGPoint(x: 0, y: 0)
        self.frame = frame

        let partsInRow = (frame.width/symbolSize).rounded(.down)
        let elementsInRow = Int((partsInRow/2).rounded())
        let xMargin = (frame.width - (CGFloat(elementsInRow)*2 - 1)*symbolSize)/2
        let yMargin = (frame.height - symbolSize) / 2

        for index in 0..<elementsInRow {
            let element = AGSymbolLayer(symbolColor: symbolColor)
            element.frame = CGRect(x: xMargin + (symbolSize*2) * CGFloat(index), y: yMargin + element.bounds.height/2, width: symbolSize, height: symbolSize)
            symbolLayers.append(element)
            addSublayer(element)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func draw(angleRule: ((_ index: Int)-> CGFloat)? = nil) {
        var angle: CGFloat

        for (index, element) in symbolLayers.enumerated() {

            if let angleRule = angleRule {
                angle = angleRule(index)
            } else {
                angle = 0
            }

            element.rotate(angle: angle, withDuration: 1)
        }
    }

    func animate() {
        var angle: CGFloat
        for (index, element) in symbolLayers.enumerated() {
            angle = index%2 == 0 ? -90: 0
            element.rotate(angle: angle, withDuration: 1)
        }
    }
}


class AGAnimatedBackgroundLayer: CAScrollLayer {

    private var rowHeight: CGFloat

    init(frame: CGRect, backgroundColor: UIColor, rowHeight: CGFloat, symbolSize: CGFloat, symbolColor: UIColor) {
        self.rowHeight = rowHeight
        super.init()
        self.frame = frame
        self.backgroundColor = backgroundColor.cgColor

        for i in 0...(Int(frame.height / rowHeight) + 1) {
            let rotationRow = AGSymbolsRowLayer(frame: CGRect(x: 0, y: CGFloat(i)*rowHeight, width: frame.width, height: rowHeight), symbolSize: symbolSize, symbolColor: symbolColor)
            rotationRow.draw()
            addSublayer(rotationRow)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animate() {
        removeAllAnimations()
        
        let scrolloingAnimation = CABasicAnimation(keyPath: "sublayerTransform.translation.y")
        scrolloingAnimation.duration = 1
        scrolloingAnimation.fromValue = 0
        scrolloingAnimation.toValue = -rowHeight
        scrolloingAnimation.repeatCount = .greatestFiniteMagnitude

        add(scrolloingAnimation, forKey: nil)
    }
}
