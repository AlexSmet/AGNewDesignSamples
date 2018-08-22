//
//  AGAnimatedBackgroundLayer.swift
//
//  Created by Alexander Smetannikov on 17/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

extension CGFloat {
    func toRadians() -> CGFloat {
       return self*CGFloat.pi/180
    }
}

public enum AnimationKind {
    case scrollUp
    case scrollDown
    case rotateUp
    case rotateDown
    case stop
}

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
    var symbolColor: UIColor!
    var defaultAngle: CGFloat!

    init(angle: CGFloat, symbolColor: UIColor) {
        defaultAngle = angle
        self.symbolColor = symbolColor
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        if let layer = layer as? AGSymbolLayer {
            symbolColor = layer.symbolColor
        }
        super.init(layer: layer)
    }

    func draw(withAngle: CGFloat? = nil) {
        path = getLetterPath().cgPath
        strokeColor = symbolColor.cgColor
        fillColor = symbolColor.cgColor
        lineWidth = 1

        let angle: CGFloat = withAngle ?? defaultAngle
        if angle != 0 {
            transform = CATransform3DMakeRotation(angle.toRadians(), 0, 0, 1)
        }
    }

    func rotate(angle: CGFloat, withDuration duration: CFTimeInterval) {
        rotate(startAngle: defaultAngle, finishAngle: angle, withDuration: duration)
    }

    func rotate(startAngle: CGFloat, finishAngle: CGFloat, withDuration duration: CFTimeInterval) {
        if duration > 0 {
//            draw(withAngle: startAngle)
//            let animation = createRotationAnimation(startAngle: startAngle, finishAngle: finishAngle, withDuration: duration)
//            add(animation, forKey: "rotation")

            transform = CATransform3DMakeRotation(finishAngle.toRadians(), 0, 0, 1)
//            draw(withAngle: finishAngle)
        } else {
            draw(withAngle: finishAngle)
        }
    }

//    func createRotationAnimation(angle: CGFloat, withDuration duration: CFTimeInterval?) -> CABasicAnimation {
//        return createRotationAnimation(startAngle: defaultAngle, finishAngle: angle, withDuration: duration)
//    }
//
//    func createRotationAnimation(startAngle: CGFloat, finishAngle: CGFloat, withDuration duration: CFTimeInterval?) -> CABasicAnimation {
//        let animation = CABasicAnimation(keyPath: "transform")
//        if let duration = duration {
//            animation.duration = duration
//        }
//        animation.fromValue = startAngle.toRadians()
//        animation.toValue = finishAngle.toRadians()
//        animation.valueFunction = CAValueFunction(name: kCAValueFunctionRotateZ)
//
//        return animation
//    }

    func getLetterPath()-> UIBezierPath {
        let scale: CGFloat = min(frame.width/340, frame.height/340)

        let path = AGSymbolPath.getPath(withScale: scale)

        return path
    }
}


class AGSymbolsRowLayer: CALayer, CAAnimationDelegate {
    private var symbolLayers: [AGSymbolLayer] = []
    private var symbolSize: CGFloat!

    private var onAnimationComplition: (()->Void)?

    init(frame: CGRect, symbolSize: CGFloat, symbolColor: UIColor, defaultAngles: [CGFloat]) {
        self.symbolSize = symbolSize

        super.init()

        anchorPoint = CGPoint(x: 0, y: 0)
        self.frame = frame

        let partsInRow = (frame.width/symbolSize).rounded(.down)
        let elementsInRow = Int((partsInRow/2).rounded())
        let xMargin = (frame.width - (CGFloat(elementsInRow)*2 - 1)*symbolSize)/2
        let yMargin = (frame.height - symbolSize) / 2

        for index in 0..<elementsInRow {
            let angleIndex =  index % defaultAngles.count
            let element = AGSymbolLayer(angle: defaultAngles[angleIndex], symbolColor: symbolColor)
            element.frame = CGRect(x: xMargin + (symbolSize*2) * CGFloat(index), y: yMargin + element.bounds.height/2, width: symbolSize, height: symbolSize)
            symbolLayers.append(element)
            addSublayer(element)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        if let layer = layer as? AGSymbolsRowLayer {
            symbolSize = layer.symbolSize
        }
        super.init(layer: layer)
    }

    func draw() {
        symbolLayers.forEach { $0.draw() }
    }

    func animate() {
        var angle: CGFloat
        for (index, element) in symbolLayers.enumerated() {
            angle = index%2 == 0 ? -90: 0
            element.rotate(angle: angle, withDuration: 1)
        }
    }

    func rotateUpAnimation() {
        symbolLayers.forEach { $0.rotate(angle: 0, withDuration: 5) }
    }

    func rotateDownAnimation() {
        symbolLayers.forEach { $0.rotate(angle: 180, withDuration: 5) }
    }

    func rotateToDefaulPositionAnimation() {
        symbolLayers.forEach { $0.rotate(angle: $0.defaultAngle, withDuration: 5) }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else {
            return
        }

        onAnimationComplition?()
    }
}


class AGAnimatedBackgroundLayer: CAScrollLayer, CAAnimationDelegate {

    private (set) var rowHeight: CGFloat!
    private var symbolSize: CGFloat!
    private var symbolColor: UIColor!

    private var needToStopAnimation = true

    private var currentAnimation: CABasicAnimation?

    private var symbolsAngles: [[CGFloat]]!

    private var rowLayers: [AGSymbolsRowLayer]? {
        get { return sublayers?.filter({ $0 is AGSymbolsRowLayer }) as? [AGSymbolsRowLayer] }
    }

    init(frame: CGRect, backgroundColor: UIColor, rowHeight: CGFloat, symbolSize: CGFloat, symbolColor: UIColor, symbolsAngles: [[CGFloat]]) {
        self.rowHeight = rowHeight
        self.symbolColor = symbolColor
        self.symbolSize = symbolSize
        self.symbolsAngles = symbolsAngles
        super.init()
        self.frame = frame
        self.backgroundColor = backgroundColor.cgColor

        draw()
    }

    override init(layer: Any) {
        if let layer = layer as? AGAnimatedBackgroundLayer {
            rowHeight = layer.rowHeight
            symbolColor = layer.symbolColor
            symbolSize = layer.symbolSize
            symbolsAngles = layer.symbolsAngles
        }

        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        
    }

    func draw() {
        for i in -1...(Int(frame.height / rowHeight) + 1) {
            let anglesIndex = abs(i % symbolsAngles.count)
            let rotationRow = AGSymbolsRowLayer(frame: CGRect(x: 0, y: CGFloat(i)*rowHeight, width: frame.width, height: rowHeight), symbolSize: symbolSize, symbolColor: symbolColor, defaultAngles: symbolsAngles[anglesIndex])
            rotationRow.draw()
            addSublayer(rotationRow)
        }
    }

    // Напрашивается выделить создание анимаций в отдельный класс

    func createScrollUpAnimation(withCycleDuration: CFTimeInterval) -> CABasicAnimation {
        let scrollingAnimation = CABasicAnimation(keyPath: "sublayerTransform.translation.y")
        scrollingAnimation.duration = 1
        scrollingAnimation.fromValue = 0
        scrollingAnimation.toValue = -rowHeight
        scrollingAnimation.repeatCount = 1
        scrollingAnimation.delegate = self

        return scrollingAnimation
    }

    func createScrollDownAnimation(withCycleDuration: CFTimeInterval) -> CABasicAnimation {
        let scrollingAnimation = CABasicAnimation(keyPath: "sublayerTransform.translation.y")
        scrollingAnimation.duration = 1
        scrollingAnimation.fromValue = 0
        scrollingAnimation.toValue = rowHeight
        scrollingAnimation.repeatCount = 1
        scrollingAnimation.delegate = self

        return scrollingAnimation
    }

    func animate(kindOfAnimation: AnimationKind) {
        removeAllAnimations()
        needToStopAnimation = false
        // создаем нужный тип анимации
        switch kindOfAnimation {
        case .scrollUp:
            sublayers?.filter({ return $0 is AGSymbolsRowLayer }).forEach({ ($0 as! AGSymbolsRowLayer).rotateUpAnimation()})
            currentAnimation = createScrollUpAnimation(withCycleDuration: 1)
        case .scrollDown:
            sublayers?.filter({ return $0 is AGSymbolsRowLayer }).forEach({ ($0 as! AGSymbolsRowLayer).rotateDownAnimation()})
            currentAnimation = createScrollDownAnimation(withCycleDuration: 1)
        case .rotateUp:
            sublayers?.filter({ return $0 is AGSymbolsRowLayer }).forEach({ ($0 as! AGSymbolsRowLayer).rotateUpAnimation()})
            currentAnimation = nil
        case .rotateDown:
            sublayers?.filter({ return $0 is AGSymbolsRowLayer }).forEach({ ($0 as! AGSymbolsRowLayer).rotateDownAnimation()})
            currentAnimation = nil
        case .stop:
            needToStopAnimation = true
            currentAnimation = nil
            sublayers?.filter({ return $0 is AGSymbolsRowLayer }).forEach({ ($0 as! AGSymbolsRowLayer).rotateToDefaulPositionAnimation()})
        }

        // стартуем анимацию
        if let currentAnimation = currentAnimation {
            add(currentAnimation, forKey: "scrolling")
        }
    }

    func stop() {
        //let loffsetY = presentation()?.value(forKeyPath: "sublayerTransform.translation.y") as? CGFloat
        needToStopAnimation = true
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else {
            return
        }

        if !needToStopAnimation {
            needToStopAnimation = false
            add(currentAnimation!, forKey: "scrolling")
        }
    }
}




